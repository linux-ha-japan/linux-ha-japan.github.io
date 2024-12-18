FROM docker.io/jekyll/jekyll:4.2.2

ENV JEKYLL_ROOTLESS=1
RUN usermod  -o -u 0 jekyll && groupmod -o -g 0 jekyll

WORKDIR /srv/jekyll/
COPY ./Gemfile /srv/jekyll/
COPY ./Gemfile.lock /srv/jekyll/

RUN bundle install

RUN default-gem-permissions && \
    sed -i -e 's%^  chown -R jekyll:jekyll /usr/gem$%#  chown -R jekyll:jekyll /usr/gem%' /usr/jekyll/bin/default-gem-permissions

CMD ["bundle", "exec", "jekyll", "serve", "--force_polling", "--host", "0.0.0.0"]

