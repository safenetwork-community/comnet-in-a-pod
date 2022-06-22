#!/bin/sh

NUM_NODES=16
NUM_JNODES=$(($NUM_NODES-1))

I_FILE_1=node_connection_info_1.config
I_FILE_2=node_connection_info_2.config
O_FILE_1=output_1.txt
O_FILE_2=output_2.txt
D_FILE_1=desired_output_1.txt
D_FILE_2=desired_output_2.txt

HOST_IPU_1=127.0.0.1
HOST_IP_1=$HOST_IP_1
HOST_PORT_1=12000

HOST_IPU_2=::1
HOST_IPR_2=\\[${HOST_IPU_2}\\]
HOST_IP_2=[$HOST_IPU_2]
HOST_PORT_2=12000

cp $I_FILE_1 $O_FILE_1
cp $I_FILE_2 $O_FILE_2

/usr/bin/nvim -es $O_FILE_1 <<-EOF
:set expandtab
:set shiftwidth=2
:let g:lastcount=${HOST_PORT_1}
:fun PlusPlus()
let l:count=g:lastcount
let g:lastcount+=1
return l:count
endfun
/\(^\|"\)\@<![
:%s//\r&\r/g
/\(\("\)\@<=]\|]$\)
:%s//\r&/g
/${HOST_IP_1}:${HOST_PORT_1}
:norm \$a,
:norm yy${NUM_JNODES}p
:norm ${NUM_JNODES}\$x
:norm gg
:%s/${HOST_IP_1}:${HOST_PORT_1}/\=printf('${HOST_IP_1}:%d', PlusPlus())
:norm gg=G
:wq!
EOF

/usr/bin/nvim -es $O_FILE_2 <<-EOF
:set expandtab
:set shiftwidth=2
:let g:lastcount=${HOST_PORT_2}
:fun PlusPlus()
let l:count=g:lastcount
let g:lastcount+=1
return l:count
endfun
/\(^\|"\)\@<![
:%s//\r&\r/g
/\(\("\)\@<=]\|]$\)
:%s//\r&/g
/${HOST_IPR_2}:${HOST_PORT_2}
:norm \$a,
:norm yy${NUM_JNODES}p
:norm ${NUM_JNODES}\$x
:norm gg
:%s/${HOST_IPR_2}:${HOST_PORT_2}/\=printf('${HOST_IP_2}:%d', PlusPlus())
:norm gg=G
:wq!
EOF

if cmp -s "$O_FILE_1" "$D_FILE_1"; then
  printf "IPv4 Succes!\n"
else
  printf "IPv4 Failure!\n\n%s\n\n" "-- output --" 
  cat $O_FILE_1
  printf "\n%s\n\n" "-- Desired output --" 
  cat $D_FILE_1
fi

printf "\n============================\n\n"

if cmp -s "$O_FILE_2" "$D_FILE_2"; then
  printf "IPv6 Succes!\n"
else
  printf "IPV6 Failure!\n\n%s\n\n" "-- output --" 
  cat $O_FILE_2
  printf "\n%s\n\n" "-- Desired output --" 
  cat $D_FILE_2
fi
