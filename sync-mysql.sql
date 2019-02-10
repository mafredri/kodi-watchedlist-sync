BEGIN;

CREATE DATABASE IF NOT EXISTS watchedlist;

CREATE TABLE IF NOT EXISTS watchedlist.tvshows (
	idShow int NOT NULL,
	title text DEFAULT NULL,
	PRIMARY KEY (idShow)
);

CREATE TABLE IF NOT EXISTS watchedlist.episode_watched (
	idShow int NOT NULL,
	season int NOT NULL,
	episode int NOT NULL,
	playCount int DEFAULT NULL,
	lastChange int DEFAULT NULL,
	lastPlayed int DEFAULT NULL,
	PRIMARY KEY (idShow, season, episode)
);

CREATE TABLE IF NOT EXISTS watchedlist.movie_watched (
	idMovieImdb int NOT NULL,
	playCount int DEFAULT NULL,
	lastChange int DEFAULT NULL,
	lastPlayed int DEFAULT NULL,
	title text DEFAULT NULL,
	PRIMARY KEY (idMovieImdb)
);

/**
 * Sync TV Shows.
 */
CREATE TEMPORARY TABLE watchedlist.tvsync
	SELECT kodi.* FROM (
		SELECT
			t.uniqueid_value AS idShow,
			t.c00 AS title,
			s.season,
			e.c13 AS episode,
			e.playCount,
			UNIX_TIMESTAMP(e.lastPlayed) AS lastPlayed
		FROM MyVideos107.episode_view e
		JOIN MyVideos107.tvshow_view t ON (t.idShow = e.idShow)
		JOIN MyVideos107.season_view s ON (s.idSeason = e.idSeason)
	) AS kodi
	LEFT JOIN watchedlist.episode_watched ew USING (idShow, season, episode)
	WHERE
		kodi.lastPlayed IS NOT NULL
		AND kodi.playCount IS NOT NULL
		AND ew.idShow IS NULL;

INSERT INTO watchedlist.tvshows
	SELECT DISTINCT(s.idShow), s.title
	FROM watchedlist.tvsync s
	LEFT JOIN watchedlist.tvshows tv USING (idShow)
	WHERE tv.idShow IS NULL;

/**
 * Ensure we're not missing any shows (bug fix for missing LEFT in the join above).
 */
INSERT INTO watchedlist.tvshows
	SELECT uniqueid_value AS idShow, t.c00 AS title
	FROM MyVideos107.tvshow_view t
	WHERE t.uniqueid_value IN (
		SELECT e.idShow
		FROM watchedlist.episode_watched e
		LEFT JOIN watchedlist.tvshows t using (idShow)
		WHERE t.idShow IS NULL
		ORDER BY idShow
	);

INSERT INTO watchedlist.episode_watched (idShow, season, episode, playCount, lastPlayed)
	SELECT idShow, season, episode, playCount, lastPlayed
	FROM watchedlist.tvsync;

DROP TEMPORARY TABLE watchedlist.tvsync;

/**
 * Sync Movies.
 */
CREATE TEMPORARY TABLE watchedlist.moviesync
	SELECT kodi.* FROM (
		SELECT
			REPLACE(uniqueid_value, 'tt', '') AS idMovieImdb,
			playCount,
			UNIX_TIMESTAMP(lastPlayed) AS lastPlayed,
			c00 AS title
		FROM MyVideos107.movie_view
	) AS kodi
	LEFT JOIN watchedlist.movie_watched mw USING (idMovieImdb)
	WHERE
		kodi.lastPlayed IS NOT NULL
		AND kodi.playCount IS NOT NULL
		AND mw.idMovieImdb IS NULL;

INSERT INTO watchedlist.movie_watched (idMovieImdb, playCount, lastPlayed, title)
	SELECT idMovieImdb, playCount, lastPlayed, title
	FROM watchedlist.moviesync;

DROP TEMPORARY TABLE watchedlist.moviesync;

COMMIT;
