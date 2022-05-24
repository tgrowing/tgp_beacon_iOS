Pod::Spec.new do |spec|
  # pod 库的名称
  spec.name         = "tgp_beacon"
 
   # pod 库的版本号，需要和远程仓库的 tag 保持一致
  spec.version      = "2.1.1"
 
   # pod 库的简介，最多140个字符
  spec.summary      = "tgp beacon framework, aim to growth."
 
   # pod 库的详细介绍，可以写一行，也可以多行，格式如下：
  spec.description  = <<-DESC
  tgp beacon framework, help customers grow.
                   DESC
 
   # pod 库的主页 URL
  spec.homepage     = "https://github.com/tgrowing/tgp_beacon_iOS"
  
  # pod 库的开源许可证
  spec.license      = { :type => 'MIT', :text => <<-LICENSE
  Copyright (c) 2018-2021 TencentGrowing.
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
                        LICENSE
                        }
  # pod 库的作者信息
  spec.author             = { "sherryssong" => "sherryssong@tencent.com" }
  
   # pod 库支持的平台和最低版本
  spec.platform     = :ios, "9.0"
  
  # pod 库的位置，一般是 Git 仓库地址
  spec.source       = { :git => "https://github.com/tgrowing/tgp_beacon_iOS.git", :tag => "#{spec.version}"  }
  
  # pod 库中包含的框架
  spec.vendored_frameworks  = "BeaconAPI_Base.framework"
  
  # 设置编译flag
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  
  # 用户的target设置
  spec.user_target_xcconfig = { 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' 
  }

end
