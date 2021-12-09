for i in $(find /proc -maxdepth 1 -type d | awk -F '/' '{print $3}' | grep -Eo "[0-9]{1,6}")
do
if [ -f /proc/$i/cmdline ]; then
      if [ "`awk 'END { print (NR > 0 && NF > 0) ? "1" : "0"}' /proc/$i/cmdline`" == "1" ]; then
          echo -n $i [ ]
          cat /proc/$i/cmdline | tr "\0" "\n" | sed '1!'D;
      else
          echo -n $i [ ]
          cat /proc/$i/comm | tr "\0" "\n" | sed '1!'D;
      fi
    fi
done
