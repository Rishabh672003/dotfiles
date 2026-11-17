"""
Writes <song>.lrc beside each file the zsh `ytmusic` function downloaded: YouTube Music's own
lyrics (synced when it has timings), else the video's captions that yt-dlp saved as
<song>.<lang>.lrc. Moon Player reads a same-named .lrc before looking anything up online.

Usage: ytmusic-lyrics.py <list>, where each line is "<video id>\t<audio file path>".
"""
import pathlib
import sys

from ytmusicapi import YTMusic


def stamp(ms):
    return f"[{ms // 60000:02d}:{ms // 1000 % 60:02d}.{ms % 1000 // 10:02d}]"


def music_lyrics(yt, video_id):
    """YouTube Music's lyrics as LRC (or plain text when untimed); None if it has none."""
    try:
        browse_id = yt.get_watch_playlist(video_id).get("lyrics")
        if not browse_id:
            return None
        found = yt.get_lyrics(browse_id, timestamps=True)
        if not found or not found.get("lyrics"):
            return None
        if found.get("hasTimestamps"):
            return "".join(f"{stamp(line.start_time)}{line.text}\n" for line in found["lyrics"])
        return found["lyrics"].strip() + "\n"
    except Exception as e:  # lookups are best effort; the download itself already worked
        print(f"  lyrics lookup failed: {e}", file=sys.stderr)
        return None


def main(list_file):
    yt = YTMusic()
    for line in pathlib.Path(list_file).read_text(encoding="utf-8").splitlines():
        video_id, _, path = line.partition("\t")
        audio = pathlib.Path(path)
        if not video_id or not audio.is_file():
            continue
        lrc = audio.with_suffix(".lrc")
        prefix = audio.stem + "."
        captions = sorted(
            p for p in audio.parent.iterdir()
            if p.name.startswith(prefix) and p.suffix == ".lrc" and p != lrc
        )

        text, source = music_lyrics(yt, video_id), "YouTube Music"
        if text is None and captions:
            # Japanese captions first, then English: the uploader's own subtitles, not auto ones.
            lang = lambda p: p.name[len(prefix):]
            pick = next((p for want in ("ja", "en") for p in captions if lang(p).startswith(want)), captions[0])
            text, source = pick.read_text(encoding="utf-8"), f"captions, {lang(pick)[:-4]}"
        for p in captions:
            p.unlink()

        if text:
            lrc.write_text(text, encoding="utf-8")
            print(f"📝 Lyrics ({source}): {lrc.name}")
        else:
            print(f"📝 No lyrics found for {audio.name}")


if __name__ == "__main__":
    main(sys.argv[1])
