#-*- coding: utf-8 -*-

# Copyright 2014, pocket
# Licensed MIT
# http://opensource.org/licenses/mit-license.php

module MikuTwitter::APIShortcuts
  def blocked_ids
    cursor_pager(self/'blocks/ids', :json, :ids, {})
  end
end

Plugin.create(:blocked_user_mute) do
  UserConfig[:blocked_user_mute_list] ||= []

  def get_block_list
    Service.primary.twitter.blocked_ids.next do |x|
      UserConfig[:blocked_user_mute_list] = x
    end
    Reserver.new(3600){get_block_list}
  end

  get_block_list

  filter_show_filter do |msgs|
    msgs = msgs.reject do |msg|
      if msg.retweet? then
        UserConfig[:blocked_user_mute_list].include?(msg.retweet_source[:user].id)
      else
        UserConfig[:blocked_user_mute_list].include?(msg.user.id)
      end
    end
    [msgs]
  end
end
