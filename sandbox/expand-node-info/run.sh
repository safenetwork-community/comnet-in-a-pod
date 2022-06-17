#!/bin/sh

I_FILE=node_connection_info.config
O_FILE=output.txt
D_FILE=desired_output.txt
HOST_IP=127.0.0.1
HOST_PORT=12000

cp $I_FILE $O_FILE

/usr/bin/nvim -e output.txt \
-c "%s/^\[/\[\\r/|%s/[^^]\[/\\r\[\\r/g" \
-c "wq!"

if cmp -s "$O_FILE" "$D_FILE"; then
  printf "Succes!\n"
else
  printf "Failure!\n\n%s\n\n" "-- output --" 
  cat $O_FILE
  printf "\n%s\n\n" "-- Desired output --" 
  cat $D_FILE
fi

#-c "set expandtab" \
#-c "set shiftwidth=2" \
#-c 'exe "norm /\"127.0.0.1:12000\"\n$a,\<ESC>yy15p14\n$x"' \
#-c "let g:lastcount=${HOST_PORT}" \
#-c 'exe "norm :fun PlusPlus()\nlet l:count=g:lastcount\nlet g:lastcount+=1\nreturn l:count\nendfun\n"' \
#-c "%s/${HOST_IP}:${HOST_PORT}/\=printf('${HOST_IP}:%d', PlusPlus())" \
#-c "norm gg=G" \

