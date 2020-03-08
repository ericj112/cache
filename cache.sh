#!/bin/bash
#cache.sh

read -p "Enter dir name to save movies: " -r save; if [[ "${save:0:1}" = "~" ]]; then if [[ "${save:1:1}" = "/" ]]; then save="${save/\~/$HOME}"; else save="${save/\~/\/home/}"; fi; fi
if [ ! -d "$save" ]; then
mkdir -p "$save"
created="yes"
else
created="no"
echo "dir already exists, using it (press ctrl+c to cancel)"
fi

if [ ! -d "$save" ]; then
echo "Could not create dir, Exiting.."
exit 1
fi

echo -n "Finding movies.."
find ~/.cache -type f | while IFS='' read -r i; do if file "$i" | grep -iq "iso media\|video"; then echo "$i"; fi; done > "$save/movies"
echo -e "\t[ OK ]"

if [ $(stat -c %s "$save/movies") -eq 0 ]; then
echo "No movies found, Exiting"
if [ "$created" = "yes" ]; then
rm "$save/movies"
rmdir "$save"
fi
exit 1
fi

echo "$(wc -l "$save/movies") movies found" 

if ! command -v mplayer 1>/dev/null 2>&1; then
echo "mplayer not found, cannot play movies"
echo "movies list was saved in $save/movies"
exit 1
fi

echo "Playing movies.."
echo "-------------------------------------------------------------"
echo "As a movie is playing, press enter to stop it to skip or save"
echo "You can press enter again to skip or y to save"
echo "-------------------------------------------------------------"
echo "Press enter to start playing the movies.."
read

for i in $(cat "$save/movies"); do mplayer "$i" 1>/dev/null 2>&1; read -p "Save file? [Y/n]: " cont; if [ "$cont" = "y" ] || [ "$cont" = "Y" ]; then read -p "Enter filename to save: " name; cp -vi "$i" "$save/$name"; fi; done

echo "Saved $(($(ls "$save" | wc -l) - 1)) movies to "$(readlink -f "$save")""
