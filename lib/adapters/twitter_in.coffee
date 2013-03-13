#
# * Copyright (c) Novedia Group 2012.
# *
# *    This file is part of Hubiquitus
# *
# *    Permission is hereby granted, free of charge, to any person obtaining a copy
# *    of this software and associated documentation files (the "Software"), to deal
# *    in the Software without restriction, including without limitation the rights
# *    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# *    of the Software, and to permit persons to whom the Software is furnished to do so,
# *    subject to the following conditions:
# *
# *    The above copyright notice and this permission notice shall be included in all copies
# *    or substantial portions of the Software.
# *
# *    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# *    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# *    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# *    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# *    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# *
# *    You should have received a copy of the MIT License along with Hubiquitus.
# *    If not, see <http://opensource.org/licenses/mit-license.php>.
#
{InboundAdapter} = require "./hadapter"
twitter = require "ntwitter"


class TwitterInboundAdapter extends InboundAdapter

  constructor: (properties) ->
    super
    @server = undefined
    @stream = undefined
    @twit = undefined


  start: ->
    unless @started
      @twit = new twitter(
        proxy: @properties.proxy
        consumer_key: @properties.consumerKey
        consumer_secret: @properties.consumerSecret
        access_token_key: @properties.twitterAccesToken
        access_token_secret: @properties.twitterAccesTokenSecret
      )
      @twit.stream "statuses/filter", track: @properties.tags, (stream) =>
        @stream = stream
        stream.on "error", (type, code) =>
          @owner.log "error", "Twitter stream error : #{type} #{code}"
        stream.on "data", (data) =>
          unless data.disconnect
            if @properties.langFilter is undefined or data.user.lang is @properties.langFilter
              hTweet = {}
              hTweetAuthor = {}
              hTweetAuthor.listed = data.user.listed_count
              hTweetAuthor.geo = data.user.geo_enabled
              hTweetAuthor.verified = data.user.verified
              hTweetAuthor.status = data.user.statuses_count
              hTweetAuthor.location = data.user.location
              hTweetAuthor.lang = data.user.lang
              hTweetAuthor.url = data.user.url
              hTweetAuthor.scrName = data.user.screen_name
              hTweetAuthor.followers = data.user.followers_count
              hTweetAuthor.profileImg = data.user.profile_image_url
              hTweetAuthor.friends = data.user.friends_count
              hTweetAuthor.description = data.user.description
              hTweetAuthor.createdAt = new Date(data.user.created_at)
              hTweetAuthor.name = data.user.name
              hTweet.id = data.id_str
              hTweet.source = data.source
              hTweet.text = data.text
              hTweet.author = hTweetAuthor
              @owner.emit "message", @owner.buildMessage(@owner.actor, "hTweet", hTweet, {author: data.user.screen_name + "@twitter.com"})
          else
            @owner.log "debug", "twitter stream close"
      super

  stop: ->
    if @started
      if @stream
        @stream.destroy
        @stream = null
      super

  update: (properties) ->
    @stop()
    for props of properties
      @properties[props] = properties[props]
    @start()


module.exports = TwitterInboundAdapter
