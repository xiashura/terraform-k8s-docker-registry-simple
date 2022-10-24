docker run                                            \
  -v $PWD/data:/data  \
  -v $PWD/exports.txt:/etc/exports:ro        \
  --cap-add SYS_ADMIN                                 \
  -p 2049:2049                                        \
  --network e49f52054435 \
  erichough/nfs-server