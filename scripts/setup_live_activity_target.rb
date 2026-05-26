#!/usr/bin/env ruby
# Adds the TenKHoursLiveActivity Widget Extension target to ios/Runner.xcodeproj.
# Idempotent — re-runs are no-ops if the target already exists.
#
# Usage: /opt/homebrew/Cellar/ruby/4.0.5/bin/ruby scripts/setup_live_activity_target.rb
# Requires: gem install xcodeproj (via Homebrew ruby; system ruby is sandboxed)

require 'xcodeproj'

PROJECT_PATH    = File.expand_path('../ios/Runner.xcodeproj', __dir__)
TARGET_NAME     = 'TenKHoursLiveActivity'
BUNDLE_ID       = 'io.wincl.tenKHours.LiveActivity'
EXT_GROUP_NAME  = 'TenKHoursLiveActivity'
EXT_DIR_RELATIVE_TO_IOS = 'TenKHoursLiveActivity'

EXT_SWIFT_SOURCES = %w[
  TenKHoursLiveActivityAttributes.swift
  TenKHoursLiveActivity.swift
  TenKHoursLiveActivityBundle.swift
]
EXT_INFO_PLIST = 'Info.plist'

CONTROLLER_FILE = 'LiveActivityController.swift'  # under Runner/

project = Xcodeproj::Project.open(PROJECT_PATH)

if project.targets.any? { |t| t.name == TARGET_NAME }
  puts "[skip] target #{TARGET_NAME} already exists"
  exit 0
end

runner_target = project.targets.find { |t| t.name == 'Runner' }
abort 'no Runner target found' if runner_target.nil?

# ── Create the Widget Extension target ───────────────────────────────────────
ext_target = project.new_target(
  :app_extension,
  TARGET_NAME,
  :ios,
  '16.2',
  nil,
  :swift,
)

ext_target.build_configurations.each do |config|
  config.build_settings.merge!(
    'PRODUCT_NAME'                      => '$(TARGET_NAME)',
    'PRODUCT_BUNDLE_IDENTIFIER'         => BUNDLE_ID,
    'INFOPLIST_FILE'                    => "#{EXT_DIR_RELATIVE_TO_IOS}/#{EXT_INFO_PLIST}",
    'IPHONEOS_DEPLOYMENT_TARGET'        => '16.2',
    'SWIFT_VERSION'                     => '5.0',
    'CODE_SIGN_STYLE'                   => 'Automatic',
    'TARGETED_DEVICE_FAMILY'            => '1,2',
    'GENERATE_INFOPLIST_FILE'           => 'NO',
    'CURRENT_PROJECT_VERSION'           => '1',
    'MARKETING_VERSION'                 => '1.0',
    'LD_RUNPATH_SEARCH_PATHS'           => '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks',
    'SKIP_INSTALL'                      => 'YES',
    'ENABLE_USER_SCRIPT_SANDBOXING'     => 'NO',
    'GCC_C_LANGUAGE_STANDARD'           => 'gnu17',
    'CLANG_CXX_LANGUAGE_STANDARD'       => 'gnu++20',
    'ENABLE_PREVIEWS'                   => 'YES',
  )
  # SwiftUI previews require -Onone in Debug. Release/Profile use the default -O.
  if config.name == 'Debug'
    config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
  end
end

# ── Create the extension's group under the main project group ────────────────
ext_group = project.main_group.find_subpath(EXT_GROUP_NAME, true)
ext_group.set_source_tree('<group>')
ext_group.set_path(EXT_DIR_RELATIVE_TO_IOS)

# ── Swift sources: add to extension; attributes also added to Runner ─────────
EXT_SWIFT_SOURCES.each do |filename|
  file_ref = ext_group.files.find { |f| f.path == filename } ||
             ext_group.new_reference(filename)
  ext_target.source_build_phase.add_file_reference(file_ref, true)
  # Attributes is shared between targets.
  if filename == 'TenKHoursLiveActivityAttributes.swift'
    runner_target.source_build_phase.add_file_reference(file_ref, true)
  end
end

# ── Info.plist reference (for INFOPLIST_FILE build setting) ──────────────────
ext_group.files.find { |f| f.path == EXT_INFO_PLIST } ||
  ext_group.new_reference(EXT_INFO_PLIST)

# ── Add LiveActivityController.swift to the Runner target ────────────────────
runner_group = project.main_group.find_subpath('Runner', false)
abort 'no Runner group' if runner_group.nil?
controller_ref = runner_group.files.find { |f| f.path == CONTROLLER_FILE } ||
                 runner_group.new_reference(CONTROLLER_FILE)
runner_target.source_build_phase.add_file_reference(controller_ref, true)

# ── Embed the extension in Runner's Copy Files (PlugIns) phase ───────────────
embed_phase = runner_target.copy_files_build_phases.find do |phase|
  phase.symbol_dst_subfolder_spec == :plug_ins
end
unless embed_phase
  embed_phase = runner_target.new_copy_files_build_phase('Embed App Extensions')
  embed_phase.symbol_dst_subfolder_spec = :plug_ins
  embed_phase.dst_path = ''
end
build_file = embed_phase.add_file_reference(ext_target.product_reference, true)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

# The Embed App Extensions phase must run BEFORE Flutter's "Thin Binary"
# script phase, otherwise xcodebuild reports a dependency cycle between the
# .appex copy and Thin Binary's outputs.
thin_phase = runner_target.build_phases.find do |p|
  p.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) &&
    p.display_name == 'Thin Binary'
end
if thin_phase
  runner_target.build_phases.delete(embed_phase)
  thin_idx = runner_target.build_phases.index(thin_phase)
  runner_target.build_phases.insert(thin_idx, embed_phase)
end

# NOTE: do NOT add an explicit Runner → Extension dependency. The Embed App
# Extensions copy-files phase creates an implicit dependency. Adding an
# explicit one on top causes an "xcodebuild Cycle inside Runner" error
# because the shared Attributes source file appears in both targets.

project.save
puts "[ok] added #{TARGET_NAME} target (bundle id #{BUNDLE_ID})"
