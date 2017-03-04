---
title: Install Haskell School of Music on Arch Linux
---

```
git clone git@github.com:Euterpea/HSoM.git && cd HSoM
stack init --force --solver --install-ghc
stack build
```

```
sudo pacman -S portmidi fluidsynth soundfont-fluid
```

test fluidsynth
```
fluidsynth -a alsa -m alsa_seq -l -i /usr/share/soundfonts/FluidR3_GM.sf2 bach_bourree.mid
```

Edit `/etc/conf.d/fluidsynth`
```
SOUND_FONT=/usr/share/soundfonts/FluidR3_GM.sf2
AUDIO_DRIVER=pulseaudio
OTHER_OPTS='-m alsa_seq -r 48000'
```

```
sudo cp /usr/lib/systemd/system/fluidsynth.service /usr/lib/systemd/user/
systemctl start fluidsynth.service
systemctl status fluidsynth.service
```

Test daemon
```
aplaymidi -p128:0 bach_bourree.mid
```

```
stack ghci
import Euterpea
playDev 2 $ c 4 en
```

Convert midi to wav
```
fluidsynth -l -T wav /usr/share/soundfonts/FluidR3_GM.sf2 test.midi -F test.wav
```
