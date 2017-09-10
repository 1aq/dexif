unit dIPTCWrite;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  dGlobal, dUtils, dMetadata, dIPTC;

type
  TIPTCWriter = class(TBasicMetadataWriter)
  private
    FIPTCSegmentStartPos: Int64;
    procedure WriteEndOfDataResourceBlock(AStream: TStream);
    procedure WriteIPTCImageResourceBlock(AStream: TStream);
  protected
    procedure WriteImageResourceBlock(AStream: TStream; AResourceID: Integer;
      AResourceName: String; ABuffer: Pointer; ABufferSize: DWord);
  public
    constructor Create(AImgData: TImgData); override;
    procedure WriteIPTCHeader(AStream: TStream);
    procedure WriteToStream(AStream: TStream); override;
  end;

  EIPTCWriter = class(Exception);

implementation

constructor TIPTCWriter.Create(AImgData: TImgData);
begin
  inherited;
  FIPTCSegmentStartPos := -1;
end;

procedure TIptcWriter.WriteEndOfDataResourceBlock(AStream: TStream);
begin
  WriteImageResourceBlock(AStream, $0B04, '', nil, 0);
end;

//------------------------------------------------------------------------------
//  Writes the IPTC header needed by JPEG files (Segment APP13 header)
//  Call WriteToStream immediately afterwards
//------------------------------------------------------------------------------
procedure TIPTCWriter.WriteIPTCHeader(AStream: TStream);
const
  SEGMENT_MARKER: array[0..1] of byte = ($FF, $ED);
  IPTC_SIGNATURE: ansistring = 'Photoshop 3.0'#0;
  SIZE: Word = 0;
begin
  FIPTCSegmentStartPos := AStream.Position;
  AStream.WriteBuffer(SEGMENT_MARKER[0], 2);
  // Next two zero bytes are the size of the entire IPTC segiment, they will be
  // replaced when the segment is completely written. For this, we store the
  // offset to the begin of the IPTC segment in FIPTCSegmentStartPos.
  AStream.WriteBuffer(SIZE, 2);
  AStream.WriteBuffer(IPTC_SIGNATURE[1], Length(IPTC_SIGNATURE));
end;

procedure TIPTCWriter.WriteIPTCImageResourceBlock(AStream: TStream);
var
  buf: ansistring;  // to do: replace by TBytes or similar, but no string!
begin
  buf := FImgData.IPTCobj.IPTCArrayToBuffer;
  WriteImageResourceBlock(AStream, $0404, '', @buf[1], Length(buf));
end;

{ Adobe image resource block:
  Length    Description
  --------- -----------
  4         Signature: '8BIM'
  2         Unique identifier for the resource. Image resource IDs contains a
            list of resource IDs used by Photoshop.
  Variable  Name: Pascal string, padded to make the size even (a null name
            consists of two bytes of 0)
  4         Actual size of resource data that follows
  Variable  The resource data, described in the sections on the individual
            resource types. It is padded to make the size even }
procedure TIPTCWriter.WriteImageResourceBlock(AStream: TStream;
  AResourceID: Integer; AResourceName: String;
  ABuffer: Pointer; ABufferSize: DWord);
const
  RESOURCE_MARKER: ansistring = '8BIM';
var
  w: Word;
  len: DWord;
begin
  // Resource marker: 8BIM
  AStream.WriteBuffer(RESOURCE_MARKER[1], Length(RESOURCE_MARKER));

  // Resource ID
  w := AResourceID;
  w := NtoBE(w);
  AStream.WriteBuffer(w, SizeOf(w));

  // Resource name
  if Length(AResourceName) = 0 then
    AStream.WriteWord(0)
  else begin
    len := Length(AResourceName);
    if len > 255 then
      raise Exception.Createfmt('Image resource name "%s" too long.', [AResourceName]);
    if not odd(len) then begin
      inc(len);
      AResourceName := AResourceName + #0;
    end;
    AStream.WriteByte(len);
    AStream.WriteBuffer(AResourceName[1], len);
  end;

  // Resource data
  if ABuffer <> nil then begin
    if odd(ABufferSize) then begin
      // Pad with zero to get even byte count
      AStream.WriteDWord(NtoBE(ABufferSize+1));
      AStream.WriteBuffer(ABuffer^, ABufferSize);
      AStream.WriteByte(0);
    end else begin
      AStream.WriteDWord(NtoBE(ABufferSize));
      AStream.WriteBuffer(ABuffer^, ABufferSize);
    end;
  end;
end;

procedure TIptcWriter.WriteToStream(AStream: TStream);
begin
  // Write the IPTC tags
  WriteIptcImageResourceBlock(AStream);

  // Write the end-of-data marker
  WriteEndOfDataResourceBlock(AStream);

  // If WriteToStream is called within a JPEG structure we must update the
  // size of the IPTC segment.
  UpdateSegmentSize(AStream, FIptcSegmentStartPos);
end;

end.
