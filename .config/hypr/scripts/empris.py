import os
import sys
import time
import subprocess

class Rofi:
  def __init__(self, args):
    self.args = args

  def select(self, prompt, options, selected):
    items = "\n".join(options)
    ans = os.popen(f"echo '{items}' | rofi -dmenu -p '{prompt}' -format i \
      -selected-row {selected} -me-select-entry ''\
      -me-accept-entry 'MousePrimary' {self.args}").read().strip()

    if ans == "":
      return -1

    return int(ans)

class PlayerList:
  def __init__(self):
    self.players = []

  def add_player(self, player):
    self.players.append(player)

  def labels(self):
    return [p.label for p in self.players]

  def playing(self):
    playing = []
    for i, player in enumerate(self.players):
      if player.playing:
        playing.append(i)
    return playing

  def name(self, index):
    return self.players[index].name

  def index(self, name):
    for i, player in enumerate(self.players):
      if name == player.name:
        return i
    return -1

class Player:
  def __init__(self, name):
    self.name = name
    label = name.split(".")[0]
    status = os.popen(f"playerctl status -p {name}").read().strip()
    if status == "Playing":
      self.playing = True
    else:
      self.playing = False
    if self.playing:
      label += " (Playing)"
    self.label = label

def get_players():
  global playerlist
  playerlist = PlayerList()

  splist = os.popen("playerctl --list-all") \
    .read().strip().split("\n")

  splist.sort()

  for name in splist:
    playerlist.add_player(Player(name))

def show_menu():
  rofi = Rofi("-font 'sans-serif 16' -theme-str 'window { width: 600px; }'")

  options = []
  options += playerlist.labels()
  options.append("---------")
  options.append("Pause All")
  options.append("Next Track")
  options.append("Prev Track")

  selected = 0
  playing = playerlist.playing()

  if len(playing) > 0:
    selected = playing[0]

  index = rofi.select("Select Player", options, selected)

  if (index == -1):
    return

  if index < len(playerlist.players):
    pause_all_except(index)
    toggleplay(index)
  else:
    if options[index] == "Pause All":
      pause_all()
    elif options[index] == "Next Track":
      go_next()
    elif options[index] == "Prev Track":
      go_prev()

def toggleplay(index):
  player = playerlist.players[index]
  if player.playing:
    pause(index)
  else:
    play(index)

def play(index):
  player = playerlist.players[index]
  if not player.playing:
    os.popen(f"playerctl -p {playerlist.name(index)} play").read()

def pause(index):
  player = playerlist.players[index]
  if player.playing:
    os.popen(f"playerctl -p {playerlist.name(index)} pause").read()

def pause_all_except(index):
  for i, _ in enumerate(playerlist.players):
    if i != index:
      pause(i)

def pause_all():
  for i, _ in enumerate(playerlist.players):
    pause(i)

def go_next():
  for player in playerlist.players:
    if player.playing:
      os.popen(f"playerctl -p {player.name} next").read()
      return

def go_prev():
  for player in playerlist.players:
    if player.playing:
      os.popen(f"playerctl -p {player.name} previous").read()
      return

def start_autopause():
  p = subprocess.Popen(["playerctl", "status", "--follow", "-f" ,"autopause - {{playerInstance}} - {{status}}"], stdout=subprocess.PIPE)

  for line in iter(p.stdout.readline, ""):
    item = line.decode('UTF-8').strip()
    if item.startswith("autopause - "):
      split = item.split(" - ")
      name = split[1]
      status = split[2]
      if status == "Playing":
        # This sleep is to avoid conflict
        # When changing players through empris manually
        time.sleep(0.25)
        get_players()
        index = playerlist.index(name)
        if index >= 0:
          player = playerlist.players[index]
          if player.playing:
            pause_all_except(index)

if (__name__ == "__main__"):
  mode = ""

  if len(sys.argv) > 1:
    mode = sys.argv[1]

  if mode == "autopause":
    start_autopause()
  else:
    get_players()
    if mode == "pauseall":
      pause_all()
    elif mode == "next":
      go_next()
    elif mode == "prev":
      go_prev()
    else:
      show_menu()