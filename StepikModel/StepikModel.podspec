Pod::Spec.new do |spec|

spec.name = "StepikModel"
spec.version = "0.0.1"
spec.summary = "Stepik model"
spec.description = "A framework for Stepik model."
spec.homepage = "https://github.com/StepicOrg/stepik-ios"
spec.license = "MIT"
spec.author = { "Ivan Magda" => "ivan.magda@stepik.org" }

spec.ios.deployment_target = "9.0"
spec.osx.deployment_target = "10.10"
spec.watchos.deployment_target = "2.0"
spec.tvos.deployment_target = "9.0"

spec.source = { :git => "https://github.com/StepicOrg/stepik-ios.git" }

spec.source_files = [
  "CocoaPodsModule.swift",
  "Sources/**/*.swift"
]
spec.exclude_files = "Package.swift"
end
