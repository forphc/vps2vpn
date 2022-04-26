#! /bin/bash
## Based from: https://serverfault.com/questions/241493/241955

nowsecs=$( date +%s )

while read account
do
    username=$( echo $account | cut -d: -f1  )
    expiredays=$( echo $account | cut -d: -f2 )
    expiresecs=$(( $expiredays * 86400 ))
    if [ $expiresecs -le $nowsecs ]
    then
        userdel -r "$username"
    fi
done < <( cut -d: -f1,8 /etc/shadow | sed /:$/d )
