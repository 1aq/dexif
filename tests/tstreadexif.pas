{ Important note:
  - Never trust a single exif extraction tool. It may just re-use other tags.
}

unit tstreadexif;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry, dEXIF;

const
  // Picture with EXIF data taken from SAMSUNG camera
  co_TestPic01 = './testpictures/original/with_exif_large.jpeg';
  co_DUTPicName01 = './testpictures/DUTPic01.jpeg';

  // Picture with EXIF data taken from CANON camera
  co_TestPic02 = './testpictures/original/img_9438.jpg';
  co_DUTPicName02 = './testpictures/DUTPic03.jpeg';

type
  { TTsTBasic_dEXIF }

  TTstReadFile_dEXIF= class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    procedure StdFloatTest(const AFileName, ATestTag: String;
      const AExpectedResult: Double; ADecimals: Integer; const AMismatchMsg: String);
    procedure StdFloatFromStringTest(const AFilename, ATestTag: String;
      const AExpectedResult: String; ADecimals: Integer; const AMismatchMsg: String);
    procedure StdIntTest(const AFileName, ATestTag: String;
      const AExpectedResult:Integer; const AMismatchMsg: String);
    procedure StdStringTest(const AFileName, ATestTag: String;
      const AExpectedResult, AMismatchMsg: String);

    procedure Test_ByteOrder(const AFilename: String; AExpected: Boolean);
    procedure Test_DateTime(const AFileName: String; AKind: Integer;
      AExpectedDateTime: TDateTime);
    procedure Test_ExposureTime(const AFilename: String; const AExpected: String);
    procedure Test_ImageSize(const AFileName: String;
      AExpectedWidth, AExpectedHeight: Integer);
    procedure Test_Resolution(const AFileName: String;
      AExpectedXResolution, AExpectedYResolution: Integer; AExpectedUnits: String);
  end;

  { Tests for image DUTPic01, taken by SAMSUNG camera }

  { TTstReadFile_dEXIF_01 }

  TTstReadFile_dEXIF_01 = class(TTstReadFile_dEXIF)
  published
    procedure TstReadFile_ApertureValue;
//    procedure TstReadFile_BitsPerSample;
    procedure TstReadFile_ByteOrder;
    procedure TstReadFile_CameraMake;
    procedure TstReadFile_CameraModel;
    procedure TstReadFile_ColorSpace;
    procedure TstReadFile_CompressedBitsPerPixel;
//    procedure TstReadFile_Compression;
    procedure TstReadFile_CustomRendered;
    procedure TstReadFile_DateTime;
    procedure TstReadFile_DateTime_Original;
    procedure TstReadFile_DateTime_Digitized;
    procedure TstReadFile_DateTime_Modified;
    procedure TstReadFile_DigitalZoomRatio;
    procedure TstReadFile_ExifImageLength;
    procedure TstReadFile_ExifImageWidth;
    procedure TstReadFile_ExifVersion;
    procedure TstReadFile_ExposureBiasValue;
    procedure TstReadFile_ExposureMode;
    procedure TstReadFile_ExposureProgram;
    procedure TstReadFile_ExposureTime;
    procedure TstReadFile_FileSource;
//    procedure TstReadFile_FirmwareVersion;
    procedure TstReadFile_Flash;
    procedure TstReadFile_FlashPixVersion;
    procedure TstReadFile_FNumber;
    procedure TstReadFile_FocalLength;
//    procedure TstReadFile_FocalLengthIn35mm;
    procedure TstReadFile_FocalPlaneXResolution;
    procedure TstReadFile_FocalPlaneYResolution;
    procedure TstReadFile_FocalPlaneResolutionUnit;
    procedure TstReadFile_ImageSize;
    procedure TstReadFile_ImageType;
    procedure TstReadFile_ISO;
    procedure TstReadFile_MaxApertureValue;
    procedure TstReadFile_MeteringMode;
    procedure TstReadFile_Orientation;
    procedure TstReadFile_Resolution;
    procedure TstReadFile_SceneCaptureType;
    procedure TstReadFile_SensingMethod;
    procedure TstReadFile_ShutterSpeedValue;
    procedure TstReadFile_WhiteBalance;
    procedure TstReadFile_YCbCrPositioning;
//  procedure TstReadFile_YCbCrSubsampling;
  end;

  { Tests for image DUTPic02, taken by CANON camera }
  TTstReadFile_dEXIF_02 = class(TTstReadFile_dEXIF)
  published
    procedure TstReadFile_ApertureValue;
//    procedure TstReadFile_BitsPerSample;
    procedure TstReadFile_ByteOrder;
    procedure TstReadFile_CameraMake;
    procedure TstReadFile_CameraModel;
    procedure TstReadFile_ColorSpace;
    procedure TstReadFile_CompressedBitsPerPixel;
//    procedure TstReadFile_Compression;
    procedure TstReadFile_CustomRendered;
    procedure TstReadFile_DateTime;
    procedure TstReadFile_DateTime_Original;
    procedure TstReadFile_DateTime_Digitized;
    procedure TstReadFile_DateTime_Modified;
    procedure TstReadFile_DigitalZoomRatio;
    procedure TstReadFile_ExifImageLength;
    procedure TstReadFile_ExifImageWidth;
    procedure TstReadFile_ExifVersion;
    procedure TstReadFile_ExposureBiasValue;
    procedure TstReadFile_ExposureMode;
    procedure TstReadFile_ExposureProgram;
    procedure TstReadFile_ExposureTime;
    procedure TstReadFile_FileSource;
//    procedure TstReadFile_FirmwareVersion;
    procedure TstReadFile_Flash;
    procedure TstReadFile_FlashPixVersion;
    procedure TstReadFile_FNumber;
    procedure TstReadFile_FocalLength;
//    procedure TstReadFile_FocalLengthIn35mm;
    procedure TstReadFile_FocalPlaneXResolution;
    procedure TstReadFile_FocalPlaneYResolution;
    procedure TstReadFile_FocalPlaneResolutionUnit;
    procedure TstReadFile_ImageSize;
    procedure TstReadFile_ImageType;
    procedure TstReadFile_ISO;
    procedure TstReadFile_MaxApertureValue;
    procedure TstReadFile_MeteringMode;
    procedure TstReadFile_Orientation;
    procedure TstReadFile_Resolution;
    procedure TstReadFile_SensingMethod;
    procedure TstReadfile_SceneCaptureType;
    procedure TstReadFile_ShutterSpeedValue;
    procedure TstReadFile_WhiteBalance;
    procedure TstReadFile_YCbCrPositioning;
//    procedure TstReadFile_YCbCrSubsampling;
  end;


implementation

uses
  FileUtil, DateUtils, Math;

{ Output of ExifTool for DUTPic01.jpeg:

    ExifTool Version Number         : 10.60
    File Name                       : DUTPic01.jpeg
    Directory                       : .
    File Size                       : 2.9 MB
    File Modification Date/Time     : 2017:08:05 11:16:56+02:00
    File Access Date/Time           : 2017:08:05 11:16:56+02:00
    File Creation Date/Time         : 2017:08:05 11:16:56+02:00
    File Permissions                : rw-rw-rw-
    File Type                       : JPEG
    File Type Extension             : jpg
    MIME Type                       : image/jpeg
    JFIF Version                    : 1.01

    Resolution Unit                 : inches
+   X Resolution                    : 300
+   Y Resolution                    : 300
+   Exif Byte Order                 : Big-endian (Motorola, MM)
+   Make                            : SAMSUNG
+   Camera Model Name               : SM-G850F
+   Exposure Time                   : 1/3376
+   F Number                        : 2.2
+   ISO                             : 40, 0                                     Tag "ISOSpeedRatings"
+   Date/Time Original              : 2017:03:15 10:35:11
+   Focal Length                    : 4.1 mm                                    Tag "FocalLength"
+   Image Width                     : 4608
+   Image Height                    : 2592
    Encoding Process                : Baseline DCT, Huffman coding
    Bits Per Sample                 : 8
    Color Components                : 3
    Y Cb Cr Sub Sampling            : YCbCr4:2:0 (2 2)
+   Aperture                        : 2.2
    Image Size                      : 4608x2592
    Megapixels                      : 11.9
+   Shutter Speed                   : 1/3376                                    Tag "ExposureTime"
+   Focal Length                    : 4.1 mm                                    Tag "FocalLength"
    Light Value                     : 15.3

----------------------

output of ccr-exif Exif Tag List for DUTPic01.jpeg

General
   Byte order	Big endian
Main IFD
   Loaded cleanly	Yes
   Camera make	SAMSUNG
   Camera model	SM-G850F
Exif sub-IFD
   Loaded cleanly	Yes
   Date/time original	Mittwoch, 15. März 2017 at 10:35:11
   Exposure time	0,000296208530805687 seconds
   F number	2,2
   Focal length	4,09
   ISO speed rating(s)	40,0

--------------------------------------------------------------------------------

Output of EXIFTool for DUTPic03.jpeg

    ExifTool Version Number         : 10.60
    File Name                       : DUTPic03.jpeg
    Directory                       : .
    File Size                       : 1478 kB
    File Modification Date/Time     : 2017:02:15 18:53:32+01:00
    File Access Date/Time           : 2017:08:07 09:51:19+02:00
    File Creation Date/Time         : 2017:08:07 09:51:19+02:00
    File Permissions                : rw-rw-rw-
    File Type                       : JPEG
    File Type Extension             : jpg
    MIME Type                       : image/jpeg
    Exif Byte Order                 : Little-endian (Intel, II)
    Make                            : Canon
    Camera Model Name               : Canon PowerShot S5 IS
    Orientation                     : Horizontal (normal)
    X Resolution                    : 180
    Y Resolution                    : 180
    Resolution Unit                 : inches
    Modify Date                     : 2017:02:11 15:09:39
    Y Cb Cr Positioning             : Centered
    Exposure Time                   : 1/1600
    F Number                        : 2.7
    ISO                             : 160
    Exif Version                    : 0220
    Date/Time Original              : 2017:02:11 15:09:39
    Create Date                     : 2017:02:11 15:09:39
    Components Configuration        : Y, Cb, Cr, -
    Compressed Bits Per Pixel       : 3
    Shutter Speed Value             : 1/1614
    Aperture Value                  : 2.7
    Max Aperture Value              : 2.7
    Flash                           : Off, Did not fire
    Focal Length                    : 6.0 mm
    Macro Mode                      : Normal
    Self Timer                      : Off
    Quality                         : Fine
    Canon Flash Mode                : Off
    Continuous Drive                : Single
    Focus Mode                      : Single
    Record Mode                     : JPEG
    Canon Image Size                : Widescreen
    Easy Mode                       : Full auto
    Digital Zoom                    : None
    Contrast                        : Normal
    Saturation                      : Normal
    Sharpness                       : 0
    Camera ISO                      : Auto High
    Metering Mode                   : Evaluative
    Focus Range                     : Auto
    AF Point                        : Manual AF point selection
    Canon Exposure Mode             : Easy
    Lens Type                       : n/a
    Max Focal Length                : 72 mm
    Min Focal Length                : 6 mm
    Focal Units                     : 100/mm
    Max Aperture                    : 2.7
    Min Aperture                    : 8
    Flash Activity                  : 0
    Flash Bits                      : (none)
    Focus Continuous                : Continuous
    AE Setting                      : Normal AE
    Image Stabilization             : On
    Display Aperture                : 2.7
    Zoom Source Width               : 3264
    Zoom Target Width               : 3264
    Spot Metering Mode              : Center
    Manual Flash Output             : n/a
    Focal Type                      : Zoom
    Focal Plane X Size              : 5.84 mm
    Focal Plane Y Size              : 4.39 mm
    Auto ISO                        : 161
    Base ISO                        : 100
    Measured EV                     : 13.38
    Target Aperture                 : 2.7
    Target Exposure Time            : 1/1614
    Exposure Compensation           : 0
    White Balance                   : Auto
    Slow Shutter                    : Off
    Shot Number In Continuous Burst : 0
    Optical Zoom Code               : 6
    Flash Guide Number              : 0
    Flash Exposure Compensation     : 0
    Auto Exposure Bracketing        : Off
    AEB Bracket Value               : 0
    Control Mode                    : Camera Local Control
    Focus Distance Upper            : 65.53 m
    Focus Distance Lower            : 0 m
    Bulb Duration                   : 0
    Camera Type                     : Compact
    Auto Rotate                     : None
    ND Filter                       : Off
    Self Timer 2                    : 0
    Flash Output                    : 0
    Canon Image Type                : IMG:PowerShot S5 IS JPEG
    Canon Firmware Version          : Firmware Version 1.01
    File Number                     : 100-9438
    Owner Name                      :
    Rotation                        : 0
    Camera Temperature              : 16 C
    Canon Model ID                  : PowerShot S5 IS
    AF Area Mode                    : Single-point AF
    Num AF Points                   : 9
    Valid AF Points                 : 1
    Canon Image Width               : 3264
    Canon Image Height              : 1832
    AF Image Width                  : 1088
    AF Image Height                 : 245
    AF Area Widths                  : 196 0 0 0 0 0 0 0 0
    AF Area Heights                 : 44 0 0 0 0 0 0 0 0
    AF Area X Positions             : 0 0 0 0 0 0 0 0 0
    AF Area Y Positions             : 0 0 0 0 0 0 0 0 0
    AF Points In Focus              : 0
    Primary AF Point                : 0
    Thumbnail Image Valid Area      : 0 159 15 104
    Super Macro                     : Off
    Date Stamp Mode                 : Off
    My Color Mode                   : Off
    Firmware Revision               : 1.01 rev 2.00
    Categories                      : (none)
    Face Detect Frame Size          : 0 0
    Face Width                      : 35
    Faces Detected                  : 0
    Image Unique ID                 : 80304b30b8ff9067a4c6cab0bda0c784
    User Comment                    :
    Flashpix Version                : 0100
    Color Space                     : sRGB
    Exif Image Width                : 3264
    Exif Image Height               : 1832
    Interoperability Index          : R98 - DCF basic file (sRGB)
    Interoperability Version        : 0100
    Related Image Width             : 3264
    Related Image Height            : 1832
    Focal Plane X Resolution        : 14506.66667
    Focal Plane Y Resolution        : 10840.23669
    Focal Plane Resolution Unit     : inches
    Sensing Method                  : One-chip color area
    File Source                     : Digital Camera
    Custom Rendered                 : Normal
    Exposure Mode                   : Auto
    Digital Zoom Ratio              : 1
    Scene Capture Type              : Standard
    Compression                     : JPEG (old-style)
    Thumbnail Offset                : 5120
    Thumbnail Length                : 4734
    Image Width                     : 3264
    Image Height                    : 1832
    Encoding Process                : Baseline DCT, Huffman coding
    Bits Per Sample                 : 8
    Color Components                : 3
    Y Cb Cr Sub Sampling            : YCbCr4:2:2 (2 1)
    Aperture                        : 2.7
    Drive Mode                      : Single-frame Shooting
    Image Size                      : 3264x1832
    Lens                            : 6.0 - 72.0 mm
    Lens ID                         : Unknown 6-72mm
    Megapixels                      : 6.0
    Scale Factor To 35 mm Equivalent: 6.1
    Shooting Mode                   : Full auto
    Shutter Speed                   : 1/1600
    Thumbnail Image                 : (Binary data 4734 bytes, use -b option to extract)
    Circle Of Confusion             : 0.005 mm
    Depth Of Field                  : inf (2.48 m - inf)
    Field Of View                   : 52.7 deg
    Focal Length                    : 6.0 mm (35 mm equivalent: 36.3 mm)
    Hyperfocal Distance             : 2.69 m
    Lens                            : 6.0 - 72.0 mm (35 mm equivalent: 36.3 - 435.8 mm)
    Light Value                     : 12.8

--------------------------------------------------------------------------------
+  <--- test is passed
-  <--- test fails, Tag not found by dExif
-------------------------------------------------------------------------------}

function ExtractFloat(s: String): Double;
const
  NUMERIC_CHARS = ['0'..'9', '.', ',', '/'];
var
  p: PChar;
  n, m: Integer;
  s1, s2: String;
  a, b: Integer;
begin
  p := PChar(@s[1]);
  n := 0;
  while (p^ <> #0) and not (p^ in NUMERIC_CHARS) do begin
    inc(p);
    inc(n);
  end;
  Delete(s, 1, n);
  if s = '' then begin
    Result := 0.0;
    exit;
  end;

  p := PChar(@s[1]);
  n := 0;
  m := 0;
  while (p^ <> #0) and (p^ in NUMERIC_CHARS) do begin
    case p^ of
      ',': p^ := '.';
      '/': begin
             s1 := Copy(s, 1, n);
             m := n+2;
           end;
    end;
    inc(p);
    inc(n);
  end;
  SetLength(s, n);
  if m > 0 then begin
    s2 := copy(s, m, MaxInt);
    a := StrToInt(s1);
    b := StrToInt(s2);
    Result := a/b;
  end else begin
    val(s, Result, n);
    if n <> 0 then Result := 0.0;
  end;
end;


{ Test methods }

procedure TTstReadFile_dEXIF.SetUp;
begin
  if not FileExists(co_DUTPicName01) then
    if FileExists(co_TestPic01) then
      CopyFile(co_TestPic01, co_DUTPicName01);

  if not FileExists(co_DUTPicName02) then
    if FileExists(co_TestPic02) then
      CopyFile(co_TestPic02, co_DUTPicName02);
end;

procedure TTstReadFile_dEXIF.TearDown;
begin
  //if FileExists(co_DUTPicName01) then
  //  DeleteFile(co_DUTPicName01);
end;


{ Generic tests }

{ Use NaN as AExpectedResult if the Tag does not exist in the image }
procedure TTstReadFile_dEXIF.StdFloatTest(const AFileName, ATestTag: String;
  const AExpectedResult: Double; ADecimals: Integer;
  const AMismatchMsg: String);
var
  DUT: TImgData;
  currStrValue: String;
  currFloatValue: Double;
  currVal, expVal: Double;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFileName);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    currFloatValue := DUT.ExifObj.GetRawFloat(ATestTag);
    if IsNaN(AExpectedResult) then begin
      currStrValue := DUT.ExifObj.LookupTagVal(ATestTag);
      CheckEquals('', currStrValue, AMismatchMsg);
    end else
    begin
      currVal := RoundTo(currFloatValue, -ADecimals);
      expVal := RoundTo(AExpectedResult, -ADecimals);
      CheckEquals(expval, currval, AMismatchMsg);
    end;
  finally
    DUT.Free;
  end;
end;

{ Compares float values passed as strings. The routine takes care of
  different decimal separators, non-numerical characters before or after the
  number, and rounds the result to the specified decimal places. }
procedure TTstReadFile_dEXIF.StdFloatFromStringTest(const AFilename, ATestTag: String;
  const AExpectedResult: String; ADecimals: Integer; const AMismatchMsg: String);
var
  DUT: TImgData;
  currStrValue: String;
  currval, expVal: Double;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFileName);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    currStrValue := DUT.ExifObj.LookupTagVal(ATestTag);
    if currStrValue = '' then
      currVal := 0.0
    else begin
      currVal := ExtractFloat(currStrValue);
      currVal := RoundTo(currVal, -ADecimals);
    end;
    if AExpectedResult = '' then
      expVal := 0.0
    else begin
      expVal := ExtractFloat(AExpectedResult);
      expVal := RoundTo(expVal, -ADecimals);
    end;
    CheckEquals(expval, currval, AMismatchMsg);
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF.StdIntTest(const AFileName, ATestTag: String;
  const AExpectedResult: Integer; const AMismatchMsg: String);
var
  DUT: TImgData;
  currIntValue: Integer;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFilename);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    currIntValue := DUT.ExifObj.GetRawInt(ATestTag); //LookupTagInt(ATestTag);
    CheckEquals(AExpectedResult, currIntValue, AMismatchMsg);
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF.StdStringTest(
  const AFileName, ATestTag, AExpectedResult, AMismatchMsg: String);
var
  DUT: TImgData;
  currStrValue: String;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFilename);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    currStrValue := DUT.ExifObj.LookupTagVal(ATestTag);

    // dEXIF strings sometimes are quoted...
    if (currStrValue <> '') and (currStrValue[1] = '"') then
      Delete(currStrValue, 1,1);
    if (currStrValue <> '') and (currStrValue[Length(currStrValue)] = '"') then
      Delete(currStrValue, Length(currStrValue), 1);

    CheckEquals(AExpectedResult, currStrValue, AMismatchMsg);
  finally
    DUT.Free;
  end;
end;

{ Aperture value }

procedure TTstReadFile_dEXIF_01.TstReadFile_ApertureValue;
begin
  StdFloatTest(co_DUTPicName01, 'ApertureValue', NaN, 1, 'Aperature value mismatch');
  // It is listed in EXIFTool output, but not in CCR.EXIF Tag List, and
  // is not found by EXIFSpy. --> NaN
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ApertureValue;
begin
  StdFloatTest(co_DUTPicName02, 'ApertureValue', 2.875, 1, 'Aperature value mismatch');
  // EXIFTool shows a value 2.7 here, but CCR.EXIF Tag List lists the value 2.875
  // that is also seen by Serif PhotoPlus X7 and EXIFSpy.
  // I suppose that EXIFTool displays the FNumber value.  --> 2.875
end;

     (*
{ Bits per sample }

procedure TTstReadFile_dEXIF_01.TstReadFile_BitsPerSample;
begin
  StdIntTest(co_DUTPicName01, 'BitsPerSample', 8, 'BitsPerSample usage mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_BitsPerSample;
begin
  StdIntTest(co_DUTPicName02, 'BitsPerSample', 8, 'BitsPerSample mismatch');
    // "Auto" --> 0
end;
*)

{ Byte order }

procedure TTstReadFile_dEXIF.Test_ByteOrder(const AFilename: String;
  AExpected: Boolean);
var
  DUT: TImgData;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFilename);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    CheckEquals(AExpected, DUT.ExifObj.MotorolaOrder, 'ByteOrder mismatch');
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_ByteOrder;
begin
  Test_ByteOrder(co_DUTPicName01, true);
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ByteOrder;
begin
  Test_ByteOrder(co_DUTPicName02, false);
end;


{ Camera Make }

procedure TTstReadFile_dEXIF_01.TstReadFile_CameraMake;
begin
  StdStringTest(co_DUTPicName01, 'Make', 'SAMSUNG', 'Camera Make mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_CameraMake;
begin
  StdStringTest(co_DUTPicName02, 'Make', 'Canon', 'Camera Make mismatch');
end;


{ Camera model }

procedure TTstReadFile_dEXIF_01.TstReadFile_CameraModel;
begin
  StdStringTest(co_DUTPicName01, 'Model', 'SM-G850F', 'Camera model mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_CameraModel;
begin
  StdStringTest(co_DUTPicName02, 'Model', 'Canon PowerShot S5 IS', 'Camera model mismatch');
end;


{ Color space }

procedure TTstReadFile_dEXIF_01.TstReadFile_ColorSpace;
begin
  StdStringTest(co_DUTPicName01, 'ColorSpace', '', 'ColorSpace mismatch');
    // Tag not available
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ColorSpace;
begin
  StdStringTest(co_DUTPicName02, 'ColorSpace', 'sRGB', 'ColorSpace mismatch');
end;


{ Compressed Bits per Pixel }

procedure TTstReadFile_dEXIF_01.TstReadFile_CompressedBitsPerPixel;
begin
  StdIntTest(co_DUTPicName01, 'CompressedBitsPerPixel', -1, 'Compressed bits per pixel mismatch');
    // Tag not specified --> -1
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_CompressedBitsPerPixel;
begin
  StdIntTest(co_DUTPicName02, 'CompressedBitsPerPixel', 3, 'Compressed bits per pixel mismatch');
end;


{   wp: not found

{ Compression }

procedure TTstReadFile_dEXIF_01.TstReadFile_Compression;
begin
  StdIntTest(co_DUTPicName01, 'Compression', -1, 'Compression mismatch');
    // Tag not specified --> -1
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_Compression;
begin
  StdIntTest(co_DUTPicName02, 'Compression', 6, 'Compression mismatch');
    // "JPEG (old style)" --> 6.
    // Other values at https://sno.phy.queensu.ca/~phil/exiftool/TagNames/EXIF.html#Compression
end;
  }


{ CustomRendered }
procedure TTstReadFile_dEXIF_01.TstReadFile_CustomRendered;
begin
  StdIntTest(co_DUTPicName01, 'CustomRendered', -1, 'CustomRendered mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_CustomRendered;
begin
  StdIntTest(co_DUTPicName02, 'CustomRendered', 0, 'CustomRendered mismatch');
    // CCR ExifList: "Normal" --> 0
end;


{ Generic Date/time test }

procedure TTstReadFile_dEXIF.Test_DateTime(const AFileName: String; AKind: Integer;
  AExpectedDateTime: TDateTime);
var
  DUT: TImgData;
  currValue: TDateTime;
begin
  DUT := TImgData.Create();
  try
    DUT.ProcessFile(AFilename);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file:'+co_DUTPicName01);
    case AKind of
      0: currValue := DUT.EXIFObj.GetImgDateTime;       // any date/time available
      1: currValue := DUT.EXIFObj.GetDateTimeOriginal;  // Tag "DateTimeOriginal"
      2: currValue := DUT.EXIFObj.GetDateTimeDigitized; // Tag "DateTimeDigitized"
      3: currValue := Dut.EXIFObj.GetDateTimeModify;    // Tag "DateTimeModify"
    end;
    CheckEquals(AExpectedDateTime, currValue, 'Date/time mismatch');
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_DateTime;
begin
  Test_DateTime(co_DUTPicName01, 0, EncodeDateTime(2017,03,15, 10,35,11,0));
    // 2017:03:15 10:35:11
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_DateTime;
begin
  Test_DateTime(co_DUTPicName02, 0, EncodeDateTime(2017,02,11, 15,09,39,0));
    // 2017:02:11 15:09:39
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_DateTime_Original;
begin
  Test_DateTime(co_DUTPicName01, 1, EncodeDateTime(2017,03,15, 10,35,11,0));
    // 2017:03:15 10:35:11
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_DateTime_Original;
begin
  Test_DateTime(co_DUTPicName02, 1, EncodeDateTime(2017,02,11, 15,09,39,0));
    // 2017:02:11 15:09:39
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_DateTime_Digitized;
begin
  Test_DateTime(co_DUTPicName01, 2, 0.0);
    // Tag not available --> 0.0
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_DateTime_Digitized;
begin
  Test_DateTime(co_DUTPicName02, 2, EncodeDateTime(2017,02,11, 15,09,39,0));
    // 2017:02:11 15:09:39
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_DateTime_Modified;
begin
  Test_DateTime(co_DUTPicName01, 3, 0.0);
    // Tag not available --> 0.0
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_DateTime_Modified;
begin
  Test_DateTime(co_DUTPicName02, 3, EncodeDateTime(2017,02,11, 15,09,39,0));
    // 2017:02:11 15:09:39
end;


{ Digital zoom ratio }

procedure TTstReadFile_dEXIF_01.TstReadFile_DigitalZoomRatio;
begin
  StdIntTest(co_DUTPicName01, 'DigitalZoomRatio', -1, 'Digital zoom ratio mismatch');
  // Tag not available in this image
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_DigitalZoomRatio;
begin
  StdIntTest(co_DUTPicName02, 'DigitalZoomRatio', 1, 'Digital zoom ratio mismatch');
end;


{ Exif image length }

procedure TTstReadFile_dEXIF_01.TstReadFile_ExifImageLength;
begin
  StdIntTest(co_DUTPicName01, 'ExifImageLength', -1, 'Exif image length mismatch');
  // Tag not available in this image
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ExifImageLength;
begin
  StdIntTest(co_DUTPicName02, 'ExifImageLength', 1832, 'Exif image length mismatch');
end;


{ Exif image width }

procedure TTstReadFile_dEXIF_01.TstReadFile_ExifImageWidth;
begin
  StdIntTest(co_DUTPicName01, 'ExifImageWidth', -1, 'Exif image width mismatch');
  // Tag not available in this image
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ExifImageWidth;
begin
  StdIntTest(co_DUTPicName02, 'ExifImageWidth', 3264, 'Exif image width mismatch');
end;


{ Exif version }

procedure TTstReadFile_dEXIF_01.TstReadFile_ExifVersion;
begin
  StdStringTest(co_DUTPicName01, 'ExifVersion', '', 'Exif version mismatch');
  // Tag not available in this image
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ExifVersion;
begin
  StdStringTest(co_DUTPicName02, 'ExifVersion', '0220', 'Exif version mismatch');
end;


{ Exposure bias value }

procedure TTstReadFile_dEXIF_01.TstReadFile_ExposureBiasValue;
begin
  StdFloatTest(co_DUTPicName01, 'ExposureBiasValue', NaN, 2, 'Exposure bias value mismatch');
  // Tag not available in this image
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ExposureBiasValue;
begin
  StdFloatTest(co_DUTPicName02, 'ExposureBiasValue', 0.0, 2, 'Exposure bias value mismatch');
end;


{ Exposure mode }

procedure TTstReadFile_dEXIF_01.TstReadFile_ExposureMode;
begin
  StdIntTest(co_DUTPicName01, 'ExposureMode', -1, 'ExposureMode mismatch');
    // Tag not specified --> -1
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ExposureMode;
begin
  StdIntTest(co_DUTPicName02, 'ExposureMode', 0, 'ExposreMode mismatch');
    // "Auto" --> 0
end;


{ Exposure program }

procedure TTstReadFile_dEXIF_01.TstReadFile_ExposureProgram;
begin
  StdIntTest(co_DUTPicName01, 'ExposureProgram', -1, 'Exposure program mismatch');
    // Tag not specified --> -1
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ExposureProgram;
begin
  StdIntTest(co_DUTPicName02, 'ExposureProgram', -1, 'Exposure program mismatch');
    // Tag not available --> -1
end;


{ Exposure time }

procedure TTstReadFile_dEXIF.Test_ExposureTime(const AFilename: String;
  const AExpected: String);
var
  DUT: TImgData;
  currStrValue: String;
  p: Integer;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFilename);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    currStrValue := DUT.ExifObj.LookupTagVal('ExposureTime');
    if currStrValue <> AExpected then begin
      p := pos('sec', currStrValue);
      if p <> 0 then Delete(currStrValue, p, MaxInt);
      p := pos('sec', AExpected);
      if p <> 0 then Delete(currStrValue, p, MaxInt);
    end;
    CheckEquals(trim(AExpected), trim(currStrValue), 'Exposure time mismatch');
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_ExposureTime;
begin
  Test_ExposureTime(co_DUTPicName01, '1/3376');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ExposureTime;
begin
  Test_ExposureTime(co_DUTPicName02, '1/1600');
end;


{ File source }

procedure TTstReadFile_dEXIF_01.TstReadFile_FileSource;
begin
  StdIntTest(co_DUTPicName01, 'FileSource', -1, 'File source mismatch');
    // Tag not specified --> -1
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_FileSource;
begin
  StdIntTest(co_DUTPicName02, 'FileSource', 3, 'File source mismatch');
    // "Digigal camera" --> 3
end;

(*                   wp: is not found..., ccr-exif EXITList lists it in MakerNotes
{ Firmware version }

procedure TTstReadFile_dEXIF_01.TstReadFile_FirmwareVersion;
begin
  StdStringTest(co_DUTPicName01, 'FirmwareVersion', '', 'Firmware version mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_FirmwareVersion;
begin
  StdStringTest(co_DUTPicName01, 'FirmwareVersion', 'Firmware Version 1.01', 'Firmware version mismatch');
end;
*)

{ Flash }

procedure TTstReadFile_dEXIF_01.TstReadFile_Flash;
begin
  StdIntTest(co_DUTPicName01, 'Flash', -1, 'Flash usage mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_Flash;
begin
  StdIntTest(co_DUTPicName02, 'Flash', 16, 'Flash usage mismatch');  // "Off, Did not fire"
  // see https://stackoverflow.com/questions/44579889/using-bitwise-to-enumerate-exif-flash-readable-string
  // "Off, did not fire" corresponds to Flash value = 16
end;


{ Flash Pix Version}

procedure TTstReadFile_dEXIF_01.TstReadFile_FlashPixVersion;
begin
  StdStringTest(co_DUTPicName01, 'FlashPixVersion', '', 'FlashPix version mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_FlashPixVersion;
begin
  StdStringTest(co_DUTPicName02, 'FlashPixVersion', '0100', 'FlashPix version mismatch');
end;


{ F Number }

procedure TTstReadFile_dEXIF_01.TstReadFile_FNumber;
begin
  StdFloatTest(co_DUTPicName01, 'FNumber', 2.2, 1, 'F number mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_FNumber;
begin
  StdFloatTest(co_DUTPicName02, 'FNumber', 2.7, 1, 'F number mismatch');
end;


{ Focal length }

procedure TTstReadFile_dEXIF_01.TstReadFile_FocalLength;
begin
  StdFloatTest(co_DUTPicName01, 'FocalLength', 4.1, 1, 'Focal length mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_FocalLength;
begin
  StdFloatTest(co_DUTPicName02, 'FocalLength', 6.0, 1, 'Focal length mismatch');
end;

                                  (*
                                  wp: failing because Calc35Equiv does not write Raw value
{ Focal length in 35 mm }

procedure TTstReadFile_dEXIF_01.TstReadFile_FocalLengthIn35mm;
begin
  StdFloatTest(co_DUTPicName01, 'FocalLengthIn35mm', NaN, 0, 'Focal length in 35mm mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_FocalLengthIn35mm;
begin
  StdFloatTest(co_DUTPicName02, 'FocalLengthIn35mm', 36, 0, 'Focal length in 35mm mismatch');
end;
                                    *)


{ Focal plane x resolution }

procedure TTstReadFile_dEXIF_01.TstReadFile_FocalPlaneXResolution;
begin
  StdFloatTest(co_DUTPicName01, 'FocalPlaneXResolution', NaN, 0, 'Focal plane X resolution mismatch');
    // This image does not contain this tag
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_FocalPlaneXResolution;
begin
  StdFloatTest(co_DUTPicName02, 'FocalPlaneXResolution', 14506.66667, 3, 'Focal plane X resolution mismatch');
end;


{ Focal plane y resolution }

procedure TTstReadFile_dEXIF_01.TstReadFile_FocalPlaneYResolution;
begin
  StdFloatTest(co_DUTPicName01, 'FocalPlaneYResolution', NaN, 0, 'Focal plane Y resolution mismatch');
    // This image does not contain this tag
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_FocalPlaneYResolution;
begin
  StdFloatTest(co_DUTPicName02, 'FocalPlaneYResolution', 10840.23669, 3, 'Focal plane Y resolution mismatch');
end;


{ Focal plane resolution unit }

procedure TTstReadFile_dEXIF_01.TstReadFile_FocalPlaneResolutionUnit;
begin
  StdIntTest(co_DUTPicName01, 'FocalPlaneResolutionUnit', -1, 'Focal plane resolution unit mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_FocalPlaneResolutionUnit;
begin
  StdIntTest(co_DUTPicName02, 'FocalPlaneResolutionUnit', 2, 'Focal plane resolution unit mismatch');
    // 'inches' --> 2
end;


{ Image width and image height }

procedure TTstReadFile_dEXIF.Test_ImageSize(const AFileName: String;
  AExpectedWidth, AExpectedHeight: Integer);
var
  DUT: TImgData;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFileName);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    CheckEquals(AExpectedWidth,  DUT.Width,  'Image width mismatch');
    CheckEquals(AExpectedHeight, DUT.Height, 'Image height mismatch');
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_ImageSize;
begin
  Test_ImageSize(co_DUTPicName01, 4608, 2592);
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ImageSize;
begin
  Test_ImageSize(co_DUTPicName02, 3264, 1832);
end;


{ Image type }

procedure TTstReadFile_dEXIF_01.TstReadFile_ImageType;
begin
  StdStringTest(co_DUTPicName01, 'ImageType', '', 'ImageType mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ImageType;
begin
  StdStringTest(co_DUTPicName02, 'ImageType', 'IMG:PowerShot S5 IS JPEG', 'ImageType mismatch');
end;


{ ISO }

procedure TTstReadFile_dEXIF_01.TstReadFile_ISO;
begin
  StdStringTest(co_DUTPicName01, 'ISOSpeedRatings', '40, 0', 'ISO mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ISO;
begin
  StdStringTest(co_DUTPicName02, 'ISOSpeedRatings', '160', 'ISO mismatch');
end;


{ Max Aperture value }

procedure TTstReadFile_dEXIF_01.TstReadFile_MaxApertureValue;
begin
  StdFloatTest(co_DUTPicName01, 'MaxApertureValue', NaN, 1, 'Max aperature value mismatch');
    // Tag not used
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_MaxApertureValue;
begin
  StdFloatTest(co_DUTPicName02, 'MaxApertureValue', 2.875, 1, 'Max aperature value mismatch');
end;


{ Metering mode }

procedure TTstReadFile_dEXIF_01.TstReadFile_MeteringMode;
begin
  StdIntTest(co_DUTPicName01, 'MeteringMode', -1, 'Metering mode mismatch');
    // Tag not used
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_MeteringMode;
begin
  StdIntTest(co_DUTPicName02, 'MeteringMode', 5, 'Metering mode mismatch');
    // ccr Exif List reports it as "Pattern" corresponding to the value 5 in
    // the EXIF documentation.
    // IrfanView calls it "MultiSegment" which is directly the dEXIF text for 5
    // Not idea what the "Evaluative" of ExifTool means...
end;



{ Orientation }

procedure TTstReadFile_dEXIF_01.TstReadFile_Orientation;
begin
  StdIntTest(co_DUTPicName01, 'Orientation', -1, 'Orientation mismatch');
    // Tag not available --> -1
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_Orientation;
begin
  StdIntTest(co_DUTPicName02, 'Orientation', 1, 'Orientation mismatch');
    // "Horizontal (normal)" --> 1
end;


{ Resolution }

procedure TTstReadFile_dEXIF.Test_Resolution(const AFileName: String;
  AExpectedXResolution, AExpectedYResolution: Integer; AExpectedUnits: String);
var
  DUT: TImgData;
  currIntValue: Integer;
  currStrValue: String;
begin
  DUT := TImgData.Create();
  try
    DUT.ProcessFile(AFileName);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    currIntValue := DUT.XResolution;
    CheckEquals(AExpectedXRESOLUTION, currIntValue, 'X resolution mismatch');
    currIntValue := DUT.YResolution;
    CheckEquals(AExpectedYRESOLUTION, currIntValue, 'Y resolution mismatch');
    currStrValue := DUT.ResolutionUnit;
    CheckEquals(lowercase(AExpectedUnits), lowercase(currStrValue), 'Resolution unit mismatch');
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_Resolution;
begin
  Test_Resolution(co_DUTPicName01, 300, 300, 'inches');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_Resolution;
begin
  Test_Resolution(co_DUTPicName02, 180, 180, 'inch');
end;


{ Scene capture type }

procedure TTstReadFile_dEXIF_01.TstReadFile_SceneCaptureType;
begin
  StdIntTest(co_DUTPicName01, 'SceneCaptureType', -1, 'Scene capture type mismatch');
    // Tag not available --> -1
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_SceneCaptureType;
begin
  StdIntTest(co_DUTPicName02, 'SceneCaptureType', 0, 'Scene capture type mismatch');
    // "Standard"  --> 0
end;


{ Sensing method }

procedure TTstReadFile_dEXIF_01.TstReadFile_SensingMethod;
begin
  StdIntTest(co_DUTPicName01, 'SensingMethod', -1, 'SensingMethod mismatch');
    // Tag not available  --> -1
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_SensingMethod;
begin
  StdIntTest(co_DUTPicName02, 'SensingMethod', 2, 'SensingMethod mismatch');
    // "One-chip color area"  --> 2
end;

{ Shutter speed value }

procedure TTstReadFile_dEXIF_01.TstReadFile_ShutterSpeedValue;
begin
  StdFloatTest(co_DUTPicName01, 'ShutterSpeedValue', NaN, 8, 'Shutter speed value mismatch');
    // Tag not available (EXIFTool does list a "Shutter Speed", but the tag is
    // not in the file, the value is probably taken from tag "ExposureTime")
    // --> NaN
end;

{ BE CAREFUL WITH THIS TEST: IT REQUIRES TRANSFORMATION OF THE EXPECTED VALUE
  SHOWN BY THE EXIF REFERENCE PROGRAM. }
procedure TTstReadFile_dEXIF_02.TstReadFile_ShutterSpeedValue;
const
  EPS = 0.01;   // Allow 1% tolerance for rounding errors etc.
var
  expectedExposureTime: Double;
  expectedShutterSpeed: Double;
  allowedDigits: Integer;
begin
  // Note: ShutterSpeedValue is stored as -log2 of exposure time.
  // see Annex C in EXIF specification
  expectedExposureTime := 1/1614;
  expectedShutterSpeed := -log2(expectedExposureTime);
  allowedDigits := round(abs(log10(EPS * expectedShutterspeed)));
  StdFloatTest(co_DUTPicName02, 'ShutterSpeedValue', expectedShutterSpeed,
    allowedDigits, 'Shutter speed value mismatch');
end;


{ White balance }

procedure TTstReadFile_dEXIF_01.TstReadFile_WhiteBalance;
begin
  StdIntTest(co_DUTPicName01, 'WhiteBalance', -1, 'WhiteBalance mismatch');
    // Tag not available  --> -1
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_WhiteBalance;
begin
  StdIntTest(co_DUTPicName02, 'WhiteBalance', 0, 'WhiteBalance mismatch');
    // "Auto"  --> 0
end;


{ YCbCr Positioning }

procedure TTstReadFile_dEXIF_01.TstReadFile_YCbCrPositioning;
begin
  StdIntTest(co_DUTPicName01, 'YCbCrPositioning', -1, 'YCbCrPositioning mismatch');
    // Tag not specified  --> -1
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_YCbCrPositioning;
begin
  StdIntTest(co_DUTPicName02, 'YCbCrPositioning', 1, 'YCbCrPositioning mismatch');
    // "centered" --> 1
end;


(*
{ YCbCr Subsampling }

procedure TTstReadFile_dEXIF_01.TstReadFile_YCbCrSubsampling;
begin
  StdStringTest(co_DUTPicName01, 'YCbCrSubsampling', 'YCbCr4:2:0 (2 2)', 'YCbCrSubsampling mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_YCbCrSubsampling;
begin
  StdStringTest(co_DUTPicName02, 'YCbCrSubsampling', 'YCbCr4:2:2 (2 1)', 'YCbCrsubsampling mismatch');
end;
*)

initialization
  RegisterTest(TTstReadFile_dEXIF_01);
  RegisterTest(TTstReadFile_dEXIF_02);

end.

