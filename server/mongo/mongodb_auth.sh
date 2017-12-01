#!/bin/bash

USER=${MONGODB_USER:-"admin"}
DATABASE=${MONGODB_DATABASE:-"admin"}
PASS=${MONGODB_PASS:-"4dminPass"}

declare -a DATABASE_LIST=(
    "user"
)


_word=$( [ ${MONGODB_PASS} ] && echo "preset" || echo "random" )

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MongoDB service startup"
    sleep 5
    mongo admin --eval "help" >/dev/null 2>&1
    RET=$?
done

echo "=> Creating an ${USER} user with a ${_word} password in MongoDB"
mongo admin --eval "db.createUser({user: '$USER', pwd: '$PASS', roles:[{role:'root',db:'admin'}]});"

for db in "${DATABASE_LIST[@]]}"
do
    echo echo "creating database auth :: $db"
    mongo "$db" --eval "db.createUser({user: '$USER', pwd: '$PASS', roles:[{role:'dbOwner',db:'$db'}]});"
    # mongoimport --db "$db" --collection "$db" --drop --file "/data/$db/mongo.json"
done

echo "=> Done!"
# touch /data/db/.mongodb_password_set

echo "========================================================================"
echo "You can now connect to this MongoDB server using:"
echo ""
echo "    mongo $DATABASE -u $USER -p $PASS --host <host> --port <port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "========================================================================"