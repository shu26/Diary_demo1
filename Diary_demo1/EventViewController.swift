//
//  EventViewController.swift
//  Diary_demo1
//
//  Created by shu26 on 2019/06/22.
//  Copyright © 2019 shu26. All rights reserved.
//

import UIKit
import RealmSwift

let w2 = UIScreen.main.bounds.size.width
let h = UIScreen.main.bounds.size.height

let eventTextView = UITextView(frame: CGRect(x: (w2 - 300) / 2, y: 100, width: 300, height: 400))
let dateLabel = UILabel(frame: CGRect(x: (w2 - 300) / 2, y: 70, width: 300, height: 20))

//var isContent: Bool

class EventViewController: UIViewController {
    var date: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //スケジュール内容入力テキスト設定
        eventTextView.text = ""
        eventTextView.font = UIFont.systemFont(ofSize: 18)
        eventTextView.backgroundColor = UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 0.1)
        eventTextView.layer.borderColor = UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 1).cgColor
        eventTextView.layer.borderWidth = 1.0
        eventTextView.layer.cornerRadius = 10.0
//        eventText.returnKeyType = .done
        view.addSubview(eventTextView)
        
        //日付表示設定
        dateLabel.backgroundColor = .white
        dateLabel.textAlignment = .center
        dateLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(dateLabel)
        
        // キーボードを閉じるためのボタンを追加する
        // ツールバー生成
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        // スタイルを設定
        toolBar.barStyle = UIBarStyle.default
        // 画面幅に合わせてサイズを変更
        toolBar.sizeToFit()
        // 閉じるボタンを右に配置するためのスペース
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.commitButtonTapped))
        // スペース、閉じるボタンを右側に配置
        toolBar.items = [spacer, commitButton]
        // textViewのキーボードにツールバーを設定
        eventTextView.inputAccessoryView = toolBar
        
        //「カレンダーに追加!」ボタン
        let eventInsert = UIButton(frame: CGRect(x: (w2 - 200) / 2, y: h - 110, width: 200, height: 50))
        eventInsert.setTitle("カレンダーに保存！", for: UIControl.State())
        eventInsert.setTitleColor(.white, for: UIControl.State())
        eventInsert.backgroundColor = UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 1)
        eventInsert.addTarget(self, action: #selector(saveEvent(_:)), for: .touchUpInside)
        view.addSubview(eventInsert)
        
        //「戻る!」ボタン
        let backBtn = UIButton(frame: CGRect(x: (w - 200) / 2, y: h - 50, width: 200, height: 30))
        backBtn.setTitle("保存しないで戻る", for: UIControl.State())
        backBtn.setTitleColor(UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 1), for: UIControl.State())
        backBtn.backgroundColor = .white
        backBtn.layer.cornerRadius = 10.0
        backBtn.layer.borderColor = UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 1).cgColor
        backBtn.layer.borderWidth = 1.0
        backBtn.addTarget(self, action: #selector(onbackClick(_:)), for: .touchUpInside)
        view.addSubview(backBtn)
    }
    
    // 画面遷移時にすでにコンテンツがある場合はそれを表示する
    override func viewWillAppear(_ animated: Bool) {
        // 選択した日付を取得
        let savedDate = UserDefaults.standard.object(forKey: "selectedDate") as! String
        dateLabel.text = savedDate
        
        let isContent = UserDefaults.standard.object(forKey: "isContent") as! Bool
        
        if isContent {
            //スケジュール取得
            let realm = try! Realm()
            var result = realm.objects(Event.self)
            result = result.filter("date = '\(savedDate)'")
            print(result)
            for ev in result {
                if ev.date == savedDate {
                    eventTextView.text = ev.event
                    print(ev.event)
                }
            }
        }
    }
    
    @objc func commitButtonTapped() {
        self.view.endEditing(true)
    }
    
    //画面遷移(カレンダーページ)
    @objc func onbackClick(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

    //DB書き込み処理
    @objc func saveEvent(_ : UIButton){
        print("データ書き込み開始")
        let realm = try! Realm()
        try! realm.write {
            //日付表示の内容とスケジュール入力の内容が書き込まれる。
            
            let Events = [Event(value: ["date": dateLabel.text, "event": eventTextView.text])]
            realm.add(Events)
            print("データ書き込み中")
        }
        print("データ書き込み完了")
        
        //前のページに戻る
        dismiss(animated: true, completion: nil)
    }
}

