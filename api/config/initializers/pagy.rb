# frozen_string_literal: true

# Pagy initializer file (6.0.4)
# Customize only what you need

# Instance variables
# See https://ddnexus.github.io/pagy/api/pagy#instance-variables
Pagy::DEFAULT[:items] = 20        # items per page
Pagy::DEFAULT[:size]  = [1, 4, 4, 1] # nav bar links

# Other variables
# See https://ddnexus.github.io/pagy/api/pagy#other-variables
Pagy::DEFAULT[:page]   = 1        # default page
Pagy::DEFAULT[:outset] = 0        # starting offset: Pagy::DEFAULT[:outset] = 0

# Backend
# See https://ddnexus.github.io/pagy/api/pagy#backend
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :empty_page    # default handling of the #pagy overflow

# Headers extra: Add Pagy headers for easier frontend implementation
require 'pagy/extras/headers'
Pagy::DEFAULT[:headers] = { page: 'Current-Page', items: 'Page-Items', count: 'Total-Count', pages: 'Total-Pages' }

# Support for arrays
require 'pagy/extras/array'

# Allow for larger page sizes when requested
Pagy::DEFAULT[:max_items] = 100   # default max items per page