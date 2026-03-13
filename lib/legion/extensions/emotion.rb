# frozen_string_literal: true

require 'legion/extensions/emotion/version'
require 'legion/extensions/emotion/helpers/valence'
require 'legion/extensions/emotion/helpers/baseline'
require 'legion/extensions/emotion/helpers/momentum'
require 'legion/extensions/emotion/runners/valence'
require 'legion/extensions/emotion/runners/gut'

module Legion
  module Extensions
    module Emotion
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
