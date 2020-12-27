FROM node:10-alpine

ENV APP=/app
ENV OUTBOUND=$APP/outbound
ENV NODE_WORKDIR=$OUTBOUND
ENV HOME=$OUTBOUND

RUN mkdir -p $OUTBOUND
RUN apk add --no-cache --update --virtual .gyp python make g++ \
    # Install Haraka
    && npm install -g Haraka --unsafe \
    && apk del .gyp

RUN haraka -i $OUTBOUND
RUN cd $OUTBOUND && node -v > .nvmrc && npm install

ADD src/haraka-serve $APP/
EXPOSE 25
EXPOSE 587

ENTRYPOINT .$APP/haraka-serve
