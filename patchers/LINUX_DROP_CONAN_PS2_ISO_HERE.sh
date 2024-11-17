#!/usr/bin/env bash

#
#  _ \  __|  __|__ __|
#  |  |(    (_ |   |
# ___/\___|\___|  _|
#
# https://github.com/conan-patches

set -euo pipefail

export EXPECTED_ISO_SHA1SUM=0b083120da3565d649f3e27c328f89c33a9c05c1

echo "DETECTIVE CONAN PS2 PATCHER"
echo "==========================="

if ! command -v zstd >/dev/null 2>&1
then
    echo "Dependency 'zstd' could not be found. Please install 'zstd' using your package manager."
    exit 1
fi

echo "[*] Applying patch to file"
export SOURCE_ISO="${1}"
echo "${SOURCE_ISO}"

echo "[*] Finding current patcher directory"
PATCHER_CWD=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "${PATCHER_CWD}"

export PATCHED_ISO="${PATCHER_CWD}/CONAN_PS2_ENGLISH_PATCHED_1.0.0.iso"
echo "${PATCHED_ISO}"

echo "[*] Finding patching data"
export PATCHDATA="${PATCHER_CWD}/patching_data/PS2_DCGT_EN_1.0.0"
echo "${PATCHDATA}"

if [ ! -d "${PATCHDATA}" ]; then
  echo "[-] Missing or corrupt patching data."
  exit 1
fi

echo "[*] Computing hash on received file"

if ! sha1sum "${SOURCE_ISO}" | grep "${EXPECTED_ISO_SHA1SUM}"; then
  echo "[-] Invalid ISO. SHA1SUM must match ${EXPECTED_ISO_SHA1SUM}."
  echo "    Please ensure that you provided the correct file and that you dumped"
  echo "    your disc correctly."
  exit 1
fi

echo "[*] Valid ISO confirmed"

export PATCHER_TEMP="${PATCHER_CWD}/temp"
export PATCHER_PATCHED_TEMP="${PATCHER_CWD}/temp/patched"
export PATCHER_PATCHED_TEMP_DATA="${PATCHER_CWD}/temp/patched/DATA"

echo "[*] Creating temp directory"
echo "${PATCHER_TEMP}"

mkdir -p "${PATCHER_TEMP}/DATA/MODULES/IRX/"
mkdir -p "${PATCHER_TEMP}/patched/DATA/"

echo "[*] Extracting ISO file"

unpack () {
  >&2 echo -n "."
  dd if="${SOURCE_ISO}" of="${PATCHER_TEMP}${1}" bs=4M iflag=skip_bytes,count_bytes count="${3}" skip="${2}" 2>/dev/null
}

unpack "/SYSTEM.CNF" 641024 57
unpack "/SLPS_254.26" 643072 2750296
unpack "/DI." 3409717248 128
unpack "/DATA/SUBDIR.HED" 1228800000 68
unpack "/DATA/MODULES.DAT" 1228802048 753664
unpack "/DATA/MODULES.HED" 1229555712 836
unpack "/DATA/DMAP.DAT" 1229557760 936116224
unpack "/DATA/DMAP.HED" 2165673984 534204
unpack "/DATA/MOVIE.DAT" 2650413056 759300096
unpack "/DATA/MOVIE.HED" 3409713152 2552
unpack "/DATA/SOUND.DAT" 2211332096 439074816
unpack "/DATA/SOUND.HED" 2650406912 4532
unpack "/DATA/STATUS.DAT" 2166208512 11616256
unpack "/DATA/STATUS.HED" 2177824768 5500
unpack "/DATA/SYSTEM.DAT" 2177830912 2621440
unpack "/DATA/SYSTEM.HED" 2180452352 5720
unpack "/DATA/ROOT.DAT" 2180458496 32768
unpack "/DATA/ROOT.HED" 2180491264 264
unpack "/DATA/2DMAP.DAT" 2180493312 12713984
unpack "/DATA/2DMAP.HED" 2193207296 7040
unpack "/DATA/PIECE.DAT" 2193215488 3424256
unpack "/DATA/PIECE.HED" 2196639744 5852
unpack "/DATA/EXTRA.DAT" 2196645888 12550144
unpack "/DATA/EXTRA.HED" 2209196032 3784
unpack "/DATA/TITLE.DAT" 2209200128 2129920
unpack "/DATA/TITLE.HED" 2211330048 1100
unpack "/DATA/MODULES/EZMIDI.IRX" 3979264 101389
unpack "/DATA/MODULES/IRX/IOPRP300.IMG" 3393536 275345
unpack "/DATA/MODULES/IRX/LIBSD.IRX" 3670016 28661
unpack "/DATA/MODULES/IRX/MCMAN.IRX" 3698688 96181
unpack "/DATA/MODULES/IRX/MCSERV.IRX" 3794944 7385
unpack "/DATA/MODULES/IRX/MODHSYN.IRX" 3803136 63037
unpack "/DATA/MODULES/IRX/MODMIDI.IRX" 3866624 21941
unpack "/DATA/MODULES/IRX/MODSEIN.IRX" 3889152 9393
unpack "/DATA/MODULES/IRX/MODSESQ.IRX" 3899392 13717
unpack "/DATA/MODULES/IRX/PADMAN.IRX" 3913728 45797
unpack "/DATA/MODULES/IRX/SDRDRV.IRX" 3960832 9161
unpack "/DATA/MODULES/IRX/SIO2MAN.IRX" 3971072 6641

echo

echo "[*] ISO file extracted"
echo "[*] Building patched ISO ${PATCHED_ISO}"

mkdir -p "${PATCHER_PATCHED_TEMP}/DATA"

zstd_patch () {
  >&2 echo -n "."
  if [[ "${1}" == "/ISOHEADER" ]]; then
    zstd --long=30 --decompress --stdout --patch-from "${PATCHER_TEMP}/SLPS_254.26" "${PATCHDATA}${1}.zstd"
  else
    zstd --long=30 --decompress --stdout --patch-from "${PATCHER_TEMP}${1}" "${PATCHDATA}${1}.zstd"
  fi
}

slack () {
  >&2 echo -n "."
  dd if=/dev/zero iflag=count_bytes count="${1}" 2>/dev/null
}

reuse () {
  >&2 echo -n "."
  cat "${PATCHER_TEMP}${1}" ;
}

(
  zstd_patch "/ISOHEADER"
  reuse "/SYSTEM.CNF" ; slack 1991
  zstd_patch "/SLPS_254.26"
  reuse "/DI." ; slack 1920
  reuse "/DATA/SUBDIR.HED" ; slack 1980
  zstd_patch "/DATA/MODULES.DAT"
  zstd_patch "/DATA/MODULES.HED" ; slack 1212
  zstd_patch "/DATA/DMAP.DAT"
  zstd_patch "/DATA/DMAP.HED" ; slack 324
  zstd_patch "/DATA/MOVIE.DAT"
  zstd_patch "/DATA/MOVIE.HED" ; slack 1544
  zstd_patch "/DATA/SOUND.DAT"
  zstd_patch "/DATA/SOUND.HED" ; slack 1612
  zstd_patch "/DATA/STATUS.DAT"
  zstd_patch "/DATA/STATUS.HED" ; slack 644
  zstd_patch "/DATA/SYSTEM.DAT"
  zstd_patch "/DATA/SYSTEM.HED" ; slack 424
  zstd_patch "/DATA/ROOT.DAT"
  zstd_patch "/DATA/ROOT.HED" ; slack 1784
  zstd_patch "/DATA/2DMAP.DAT"
  zstd_patch "/DATA/2DMAP.HED" ; slack 1152
  zstd_patch "/DATA/PIECE.DAT"
  zstd_patch "/DATA/PIECE.HED" ; slack 292
  zstd_patch "/DATA/EXTRA.DAT"
  zstd_patch "/DATA/EXTRA.HED" ; slack 312
  zstd_patch "/DATA/TITLE.DAT"
  zstd_patch "/DATA/TITLE.HED" ; slack 948
  reuse "/DATA/MODULES/EZMIDI.IRX" ; slack 1011
  reuse "/DATA/MODULES/IRX/IOPRP300.IMG" ; slack 1135
  reuse "/DATA/MODULES/IRX/LIBSD.IRX" ; slack 11
  reuse "/DATA/MODULES/IRX/MCMAN.IRX" ; slack 75
  reuse "/DATA/MODULES/IRX/MCSERV.IRX" ; slack 807
  reuse "/DATA/MODULES/IRX/MODHSYN.IRX" ; slack 451
  reuse "/DATA/MODULES/IRX/MODMIDI.IRX" ; slack 587
  reuse "/DATA/MODULES/IRX/MODSEIN.IRX" ; slack 847
  reuse "/DATA/MODULES/IRX/MODSESQ.IRX" ; slack 619
  reuse "/DATA/MODULES/IRX/PADMAN.IRX" ; slack 1307
  reuse "/DATA/MODULES/IRX/SDRDRV.IRX" ; slack 1079
  reuse "/DATA/MODULES/IRX/SIO2MAN.IRX" ; slack 1551
) > "${PATCHED_ISO}"

echo

echo "[*] ISO file built"

echo "[*] Cleaning temp directory"
rm -rf "${PATCHER_TEMP}"

echo "[*] Build success. Thank you for using this patcher."
echo "${PATCHED_ISO}"

