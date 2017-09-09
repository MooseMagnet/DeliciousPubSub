Pod::Spec.new do |spec|
  spec.name = "DeliciousPubSub"
  spec.version = "1.1.0"
  spec.summary = "Swift PubSub, strongly typed. Delicious. Nutritious."
  spec.homepage = "https://github.com/moosemagnet/deliciouspubsub"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Skylark" => 'skylark@devsword.com' }
  spec.platform = :ios, "9.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/moosemagnet/deliciouspubsub.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "DeliciousPubSub/**/*.{h,swift}"
end
