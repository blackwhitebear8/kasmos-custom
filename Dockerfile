FROM kasmweb/kasmos-desktop:1.16.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

# installing termius
COPY update-discord.sh /tmp/install-discord.sh
COPY notepadnext.desktop /usr/share/applications/notepadnext.desktop

RUN  wget --no-hsts https://www.termius.com/download/linux/Termius.deb \
    && apt install -y ./Termius.deb \
    && sed -i 's|Exec=/opt/Termius/termius-app %U|Exec=/opt/Termius/termius-app --no-sandbox %U|' /usr/share/applications/termius-app.desktop \
    && rm Termius.deb \

    && chmod +x /tmp/install-discord.sh \
    && sh /tmp/install-discord.sh \
    && dpkg -i /tmp/discord.deb || apt-get install -f -y \
    && sed -i 's|Exec=/usr/share/discord/Discord|Exec=/usr/share/discord/Discord --no-sandbox|' /usr/share/applications/discord.desktop \
    && rm /tmp/discord.deb \
    && rm /tmp/install-discord.sh \

    && wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | tee /etc/apt/sources.list.d/element-io.list \
    && apt update -y \
    && apt install -y element-desktop \
    && sed -i 's|Exec=/opt/Element/element-desktop %U|Exec=/opt/Element/element-desktop --no-sandbox %U|' /usr/share/applications/element-desktop.desktop \

    && mkdir -p /opt/notepadnext \
    && wget -O /opt/notepadnext/notepadnext.AppImage https://github.com/dail8859/NotepadNext/releases/download/v0.8/NotepadNext-v0.8-x86_64.AppImage \
    && chmod +x /opt/notepadnext/notepadnext.AppImage \
    && cd /opt/notepadnext \
    && ./notepadnext.AppImage --appimage-extract \
    && cd /home/kasm-default-profile \

    && apt remove -y zoom* \

    && apt install -y vlc htop mtr net-tools neofetch \

    && apt update -y \
    && apt upgrade -y \
    && apt autoremove -y

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
