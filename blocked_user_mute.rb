#-*- coding: utf-8 -*-

# Copyright 2014, pocke
# Licensed MIT
# http://opensource.org/licenses/mit-license.php

require 'set'


module MikuTwitter::APIShortcuts
  def blocked_ids
    cursor_pager(self/'blocks/ids', :json, :ids, {})
  end
end


class BlockedUserMuter
  def initialize
    @user_list = Set.new
    update
  end

  def update
    Service.primary.twitter.blocked_ids.next do |x|
      @user_list = x.to_set
    end
  end

  def target?(id)
    return @user_list.include?(id)
  end

  def add(target_id)
    @user_list.add(target_id)
  end
end


Plugin::Streaming::Streamer.defevent(:block) do |json|
  source = MikuTwitter::ApiCallSupport::Request::Parser.user(json['source'].symbolize)
  target = MikuTwitter::ApiCallSupport::Request::Parser.user(json['target'].symbolize)
  Plugin.call(:block, source, target)
end


Plugin.create(:blocked_user_mute) do
  muter = BlockedUserMuter.new

  -> {
    updater = -> {
      muter.update
      Reserver.new(3600){updater.call}
    }
    updater.call
  }.call

  filter_show_filter do |msgs|
    msgs = msgs.reject do |msg|
      id = msg.retweet? ? msg.retweet_source[:user].id : msg.user.id

      muter.target?(id)
    end
    [msgs]
  end

  on_block do |source, target|
    muter.add(target.id)
    # hide tweet.
    Plugin.call(:destroyed, ObjectSpace.each_object(Message).to_a.select{|m| m.user == target})
  end
end
