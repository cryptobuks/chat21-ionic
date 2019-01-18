# environment=$(< src/utils/constants.ts)
# start="CURR_VER_DEV = '"
# end="'"
# one=${environment#*$start}
# build=${one%%$end*} #two=${one%,*} -> %% prendo la prima istanza; % prendo la seconda
# NEW_BUILD=$(($build + 1))
environment=$(< src/utils/constants.ts)
start="CURR_VER_DEV = '"
two="."
end="'"

str=${environment#*$start}
ver=${str%%$two*}
str=${str#*$two}
build=${str%%$end*}
echo 'ver: ---->'$ver
echo 'build: ---->'$build

newbuild=$(echo "$build + 1" | bc)
if (( $newbuild == 1000 )); then
    NEW_VER=$(echo "$ver + 1" | bc)
    NEW_BUILD=$(printf "%03d" 0)
else
    NEW_VER=$ver
    NEW_BUILD=$(printf "%03d" $newbuild)
fi
echo 'ver: ---->'$NEW_VER
echo 'build: ---->'$NEW_BUILD

sed -i -e "s/$start$build/$start$NEW_BUILD/g" src/utils/constants.ts
ionic cordova platform add browser --save
ionic cordova build browser

cp -p src/firebase-messaging-sw.js platforms/browser/www/
cp -p src/manifest.json platforms/browser/www/
cd platforms/browser/www
aws s3 sync . s3://tiledesk-dashboard/chat/dev/$NEW_VER/$NEW_BUILD/
cd ../../../

echo new version deployed on s3://tiledesk-dashboard/chat/dev/$NEW_VER/$NEW_BUILD/
echo available on https://s3.eu-west-1.amazonaws.com/tiledesk-dashboard/chat/dev/$NEW_VER/$NEW_BUILD/index.html
