#!/usr/bin/env ruby

#
#	HtmlGrid -- HyperTextMarkupLanguage Framework
#	Copyright (C) 2003 ywesee - intellectual capital connected
# Andreas Schrafl, Benjamin Fay, Hannes Wyss, Markus Huggler
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#	ywesee - intellectual capital connected, Winterthurerstrasse 52, CH-8006 Zuerich, Switzerland
#	htmlgrid@ywesee.com, www.ywesee.com/htmlgrid
#
# Label -- htmlgrid -- 26.11.2002 -- hwyss@ywesee.com

require "delegate"
require "htmlgrid/namedcomponent"

module HtmlGrid
  class SimpleLabel < NamedComponent
    def init
      super
      @value = @lookandfeel.lookup(@name)
      state = @session.state
      if state.respond_to?(:mandatory?) && state.mandatory?(@name)
        @value += "*"
      end
    end

    def to_html(context)
      context.label(@attributes) { @value }
    end
  end

  class Label < SimpleDelegator
    include Enumerable
    def initialize(component, session, label_key = nil)
      @component = component
      @attributes = {}
      @session = session
      @lookandfeel = session.lookandfeel
      @label_key = label_key
      if @component.respond_to? :name
        @attributes["for"] = @component.name.to_s
        @label_key ||= @component.name
      end
      if @component.respond_to?(:data_origin) \
         && (origin = @component.data_origin)
        @attributes.store("title", origin.to_s)
      end
      if @session.error(@label_key) \
         || (@component.respond_to?(:name) && @session.error(@component.name))
        @attributes["class"] = "error"
      end
      if @component.respond_to?(:attributes) \
        && (id = @component.attributes["id"])
        @attributes.store("id", "label_#{id}")
      end
      super(component)
    end

    def each
      yield self if @component.respond_to?(:label?) && @component.label?
      yield @component
    end

    def to_html(context)
      key = @label_key
      label = @lookandfeel.lookup(key)
      if !label && @component.respond_to?(:name)
        key = @component.name
        label = @lookandfeel.lookup(key)
      end
      state = @session.state
      if label && state.respond_to?(:mandatory?) && state.mandatory?(key)
        label += "*"
      end
      if label
        context.label(@attributes) { label }
      end
    end
  end
end
