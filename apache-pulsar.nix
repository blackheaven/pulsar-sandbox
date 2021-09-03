{ mkDerivation, aeson, async, base, bytestring, streamly, supernova, text, lib }:

mkDerivation {
  pname = "pulsar-sandbox";
  version = "0.1.0";
  src = ./.;
  libraryHaskellDepends = [ aeson async base bytestring streamly supernova text ];
  homepage = "http://github.com/blackheaven/pulsar-sandbox";
  description = "Pulsar sandbox";
  license = lib.licenses.bsd3;
}
