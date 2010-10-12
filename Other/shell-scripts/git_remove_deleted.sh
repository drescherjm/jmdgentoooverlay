eg status | grep deleted | sed s'#deleted:##g' | xargs -n1 -i eg rm {}
