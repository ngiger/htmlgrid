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
# Image -- htmlgrid -- 27.11.2002 -- hwyss@ywesee.com

require "htmlgrid/namedcomponent"

module HtmlGrid
  class Image < NamedComponent
    def init
      super
      if @lookandfeel
        @attributes["src"] = @lookandfeel.resource(@name)
        @attributes["alt"] = @lookandfeel.lookup(@name)
      end
      # @attributes['border'] = "0"
    end

    def to_html(context)
      context.img(@attributes)
    end
  end
end
