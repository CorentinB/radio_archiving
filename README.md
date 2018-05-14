# Radio Archiving
Tools for (web) radio stations archiving.

# Usage

```
./radio_archiving DURATION
```

DURATION can be expressed in s, m, h or d.
Example:
```
./radio_archiving 24h
```
This command will archive 24h of radio, based on the urls.txt file. Then loop to another 24h, etc.

# Testing urls

```
./check_urls_list
```

This will check the urls list in this repo.
If any url doesnt work, it will be writtent in the $(date)_dead_urls.txt file.
Please replace dead urls and push the new urls.txt file.
