Hey there! welcome to my nyarch KDE spin! glad you're here, sadly it's still in progress but due within the week!

Stuff to change to make it work on your pc:
in ``steps.sh`` you need to change the output directory to wherever you want it. the current directory i have it in is so i dont have to sudo mv the iso everytime to that directory!
that's about it for that. if you want to do this type of thing (specifically for nyarch) i recommend adding my repo (PersonalRepo) in ``pacman.conf`` and adding ``python313`` to your ``packages.x86_64`` since that will download the required python library for calamares to load.

that's about it. this repo may be moved to NyarchLinux since they host all the files. ill try to keep this file in so yall can read it and understand what to do.

<img width="630" height="630" alt="image" src="https://github.com/user-attachments/assets/718f6adc-51e5-4818-8a07-05ae39625e76" />
