# frozen_string_literal: true

ActiveModelSerializers.config.adapter = :json
ActiveModelSerializers.config.jsonapi_resource_type = :singular
ActiveModelSerializers.config.default_includes = '**'
