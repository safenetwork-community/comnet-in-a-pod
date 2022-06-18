#!/bin/sh

I_FILE=node_connection_info.config
O_FILE=output.txt
D_FILE=desired_output.txt
HOST_IP=127.0.0.1
HOST_PORT=12000

cp $I_FILE $O_FILE

/usr/bin/nvim -es $O_FILE <<-EOF
:set expandtab
:set shiftwidth=2
:let g:lastcount=${HOST_PORT}
:fun PlusPlus()
let l:count=g:lastcount
let g:lastcount+=1
return l:count
endfun
:s/\[\([^][]*\)/[\\r\1\\r/g|s/]/&\\r/
/${HOST_IP}:${HOST_PORT}
:norm \$a,
:norm yy15p
:norm 15\$x
:norm gg
:%s/${HOST_IP}:${HOST_PORT}/\=printf('${HOST_IP}:%d', PlusPlus())
:norm gg=G
:wq!
EOF

if cmp -s "$O_FILE" "$D_FILE"; then
  printf "Succes!\n"
else
  printf "Failure!\n\n%s\n\n" "-- output --" 
  cat $O_FILE
  printf "\n%s\n\n" "-- Desired output --" 
  cat $D_FILE
fi
