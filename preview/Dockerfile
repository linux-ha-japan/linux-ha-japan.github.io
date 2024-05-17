FROM docker.io/jekyll/jekyll:4.2.2

ENV JEKYLL_ROOTLESS=1

WORKDIR /srv/jekyll/
COPY ./Gemfile /srv/jekyll/
COPY ./Gemfile.lock /srv/jekyll/

RUN bundle install
CMD ["bundle", "exec", "jekyll", "serve", "--force_polling", "--host", "0.0.0.0"]

