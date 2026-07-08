#!/usr/bin/env ruby
# GeocodePlugin.swift / .m を App ターゲットに登録する
require 'xcodeproj'

proj_path = File.join(__dir__, 'App.xcodeproj')
project = Xcodeproj::Project.open(proj_path)

target = project.targets.find { |t| t.name == 'App' }
abort('App ターゲットが見つかりません') unless target

# App グループ（AppDelegate.swift がある論理グループ）を探す
app_group = project.main_group.find_subpath('App', true)

files = ['GeocodePlugin.swift', 'GeocodePlugin.m']
files.each do |fname|
  disk_path = File.join(__dir__, 'App', fname)
  unless File.exist?(disk_path)
    puts "  [skip] 実ファイルが無い: #{disk_path}"
    next
  end

  # 既に登録済みならスキップ
  already = project.files.any? { |f| f.path && File.basename(f.path) == fname }
  if already
    puts "  [ok] 登録済み: #{fname}"
    next
  end

  ref = app_group.new_reference(disk_path)
  target.add_file_references([ref])
  puts "  [add] 追加: #{fname}"
end

project.save
puts '完了: App.xcodeproj を保存しました'
