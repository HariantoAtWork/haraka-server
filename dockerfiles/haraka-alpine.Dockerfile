FROM node:14-alpine

ENV APP=/app
ENV OUTBOUND=$APP/outbound
ENV NODE_WORKDIR=$OUTBOUND
ENV HOME=$OUTBOUND

RUN mkdir -p $OUTBOUND
RUN apk add --no-cache --update --virtual .gyp python make g++ \
    # Install Haraka
    && npm install -g Haraka --unsafe \
    && apk del .gyp \
    && apk add --update openssl

RUN haraka -i $OUTBOUND
RUN cd $OUTBOUND && node -v > .nvmrc && npm install

ADD src/haraka-serve $APP/
ENV WORKDIR=$OUTBOUND
EXPOSE 25
EXPOSE 587

ENTRYPOINT .$APP/haraka-serve
