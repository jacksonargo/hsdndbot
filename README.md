# hsdndbot
An IRC bot for HSDND written in Ruby with Cinch

##Launch the bot:

    docker run --env DB_HOST=mongo --env DB_USER=myuser --env DB_PASS=mypass jacksonargo/hsdndbot rails runner scripts/hsdndbot.rb

##Launch the backend website:

    docker run --env DB_HOST=mongo --env DB_USER=myuser --env DB_PASS=mypass jacksonargo/hsdndbot
