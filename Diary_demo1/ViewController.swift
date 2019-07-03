//
//  ViewController.swift
//  Diary_demo1
//
//  Created by shu26 on 2019/06/20.
//  Copyright © 2019 shu26. All rights reserved.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

let w = UIScreen.main.bounds.size.width
let h = UIScreen.main.bounds.size.height

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    let dateView = FSCalendar(frame: CGRect(x: 0, y: 30, width: w, height: 400))
    let scheduleView = UIView(frame: CGRect(x: 0, y: 430, width: w, height: h))
    let contentLabel = UILabel(frame: CGRect(x: 5, y: 120, width: 400, height: 100))
    let titleLabel = UILabel(frame: CGRect(x: 0, y: 80, width: 180, height: 40))
    let selectedDate = UILabel(frame: CGRect(x: 5, y: 0, width: 200, height: 100))
    var toEditDate: String?
    var isContent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //カレンダー設定
        self.dateView.dataSource = self
        self.dateView.delegate = self
        self.dateView.today = nil
        self.dateView.tintColor = .red
        self.view.backgroundColor = .white
        dateView.backgroundColor = .white
        view.addSubview(dateView)
        
        scheduleView.backgroundColor = UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 0.8)
        view.addSubview(scheduleView)
        
        //日付表示設定
        selectedDate.text = ""
        selectedDate.font = UIFont.systemFont(ofSize: 40.0)
        selectedDate.textColor = .white
        scheduleView.addSubview(selectedDate)
        
        //「主なスケジュール」表示設定
        titleLabel.text = ""
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20.0)
        scheduleView.addSubview(titleLabel)
        
        //スケジュール内容表示設定
        contentLabel.text = ""
        contentLabel.font = UIFont.systemFont(ofSize: 18.0)
        scheduleView.addSubview(contentLabel)
        
        //スケジュール追加ボタン
        let addBtn = UIButton(frame: CGRect(x: w - 80, y: h - 90, width: 60, height: 60))
        addBtn.setTitle("+", for: UIControl.State())
        addBtn.setTitleColor(.white, for: UIControl.State())
        addBtn.backgroundColor = UIColor(red: 0/255, green: 100/255, blue: 255/255, alpha: 1)
        addBtn.layer.cornerRadius = 30.0
        addBtn.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
        view.addSubview(addBtn)
        
        // 今日の日付を取得する
        let now = Date()
        let todayDateFormatter = DateFormatter()
        todayDateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        let today = todayDateFormatter.string(from: now)
        selectedDate.text = today
        
        // カレンダー上でも選択する
        dateView.select(now)
        calendar(dateView, didSelect: now, at: .current)
    }
    
    // 編集画面から戻ってきたときに編集内容を自動更新
    override func viewWillAppear(_ animated: Bool) {
        contentLabel.text = "スケジュールはありません"
        contentLabel.textColor = .darkGray
        
        // カレンダー上でも選択する
        let savedDate = UserDefaults.standard.object(forKey: "selectedDate") as? String
        if savedDate != nil {
            let date = savedDate!
            getSchedule(date: date)
        }
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // 祝日判定を行い結果を返すメソッド
    func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
        
        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    
    //曜日判定
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //祝日判定をする
        if self.judgeHoliday(date){
            return UIColor.red
        }
        //土日の判定
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {
            return UIColor.red
        }
        else if weekday == 7 {
            return UIColor.blue
        }
        return nil
    }
    
    //画面遷移(スケジュール登録ページ)
    @objc func onClick(_: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let SecondController = storyboard.instantiateViewController(withIdentifier: "Insert")
        UserDefaults.standard.set(toEditDate, forKey: "selectedDate")
        UserDefaults.standard.set(isContent, forKey: "isContent")
        present(SecondController, animated: true, completion: nil)
    }
    
    
    //カレンダー処理(スケジュール表示処理)
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        
        titleLabel.text = "主なスケジュール"
        titleLabel.backgroundColor = .white
        
        //予定がある場合、スケジュールをDBから取得・表示する。
        //無い場合、「スケジュールはありません」と表示。
        contentLabel.text = "スケジュールはありません"
        contentLabel.textColor = .darkGray
        isContent = false
        // テキストの折り返し
        // 以下，UILabelの高さが足らないため，機能していない
//        contentLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        let m = String(format: "%02d", month)
        let d = String(format: "%02d", day)
        
        let da = "\(year)/\(m)/\(d)"
        
        //クリックしたら、日付が表示される。
        selectedDate.text = "\(m)/\(d)"
        toEditDate = da
        
        getSchedule(date: da)
    }
    
    func getSchedule(date: String) {
        //スケジュール取得
        let realm = try! Realm()
        var result = realm.objects(Event.self)
        result = result.filter("date = '\(date)'")
        print(result)
        for ev in result {
            if ev.date == date {
                contentLabel.text = ev.event
                print(ev.event)
                contentLabel.textColor = .black
                // コンテンツがすでにある場合
                isContent = true
            }
        }
    }

}
