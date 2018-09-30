# kodi-watchedlist-sync

Sync Kodi watched status without watchedlist plugin (MySQL)

**Purpose:** I'm currently using Mr.MC which has no watchedlist plugin. Mostly I'm a data hoarder and want to keep my watched list forever. This is a quick hack to keep syncing watched status from Mr.MC into a `watchedlist.db` compatible format.

Beware, you must be using a MySQL-compatible database backend for Kodi/Mr.MC and run the SQL directly against the DB.

## Limitations

* This is only a one-way sync (from Kodi)
* Doesn't handle marking stuff as unwatched
* Did not confirm if it updates playcounts or not
* You're still repsonsible for backing up the new `watchedlist` db in your Kodi database
