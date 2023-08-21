inspired by https://github.com/home-assistant/operating-system

## Steps to build
### Add a new config mirroring buildroot upstream
`ln -s ../../buildroot/configs/raspberrypi4_64_defconfig buildroot-external/configs/raspberrypi4_64_defconfig`
### Generate config and build image
 - `make raspberrypi4_64-config`
 - `make raspberrypi4_64`
