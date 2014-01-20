#-*- coding: utf-8 -*-

# Copyright 2014, pocke
# Licensed MIT
# http://opensource.org/licenses/mit-license.php

require 'bsearch'

module MikuTwitter::APIShortcuts
  def blocked_ids
    cursor_pager(self/'blocks/ids', :json, :ids, {})
  end
end

Plugin.create(:blocked_user_mute) do
  UserConfig[:blocked_user_mute_list] ||= []

  def get_block_list
    Service.primary.twitter.blocked_ids.next do |x|
      UserConfig[:blocked_user_mute_list] = x.sort
    end
    Reserver.new(3600){get_block_list}
  end

  get_block_list

  filter_show_filter do |msgs|
    msgs = msgs.reject do |msg|
      UserConfig[:blocked_user_mute_list].bsearch do |x|
        x <=> (msg.retweet? ? msg.retweet_source[:user].id : msg.user.id)
      end
    end
    [msgs]
  end
end
