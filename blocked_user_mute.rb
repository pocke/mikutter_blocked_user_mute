#-*- coding: utf-8 -*-

# Copyright 2014, pocke
# Licensed MIT
# http://opensource.org/licenses/mit-license.php


module MikuTwitter::APIShortcuts
  def blocked_ids
    cursor_pager(self/'blocks/ids', :json, :ids, {})
  end
end


class BlockedUserMuter
  def initialize
    @user_list = []
    update
  end

  def update
    Service.primary.twitter.blocked_ids.next do |x|
      @user_list = x.sort
    end
  end

  def target?(id)
    i = @user_list.bsearch do |x|
      x >= id
    end

    return i == id
  end
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
end
