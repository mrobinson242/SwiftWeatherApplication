import UIKit
import Charts

class WeeklyTabController: UIViewController
{
    // MARK: Properties
    
    // Weekly Info
    var summary = "Light rain throughout the week"
    var iconName = "wind"
    
    // Min/Max Temp Data
    var minTempData = [Double]()
    var maxTempData = [Double]()
    
    // Links to Weather Summary View
    @IBOutlet var firstSubView: UIView!
    @IBOutlet var wIcon: UIImageView!
    @IBOutlet weak var summaryValue: UILabel!

    // Link Temperature Line Chart
    @IBOutlet weak var lineChart: LineChartView!

    // MARK: Initialization
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Styling of First Sub View
        self.firstSubView.layer.cornerRadius = 10;
        self.firstSubView.layer.masksToBounds = true;
        self.firstSubView.layer.borderWidth = 1
        self.firstSubView.layer.borderColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 0.5).cgColor
        
        // Styling of Line Graph
        self.lineChart.layer.backgroundColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 0.3).cgColor
        self.lineChart.layer.borderWidth = 1
        self.lineChart.layer.borderColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 0.5).cgColor
      
        // Update Weather Summary View
        updateWeatherSummaryView()
        
        // Create Graph
        createLineGraph()
    }
    
    //
    // updateWeatherSummaryView
    //
    func updateWeatherSummaryView()
    {
        self.summaryValue.text = "\(self.summary)"
        getWeatherIcon()
    }

    //
    // getWeatherIcon
    //
    func getWeatherIcon()
    {
        // Get Icons
        if("clear-day" == self.iconName){ self.wIcon.image = UIImage(named: "weather-sunny")! }
        if("clear-night" == self.iconName){ self.wIcon.image = UIImage(named: "weather-night")! }
        if("rain" == self.iconName){ self.wIcon.image = UIImage(named: "weather-rainy")! }
        if("snow" == self.iconName){ self.wIcon.image = UIImage(named: "weather-snowy")! }
        if("sleet" == self.iconName){ self.wIcon.image = UIImage(named: "weather-snowy-rainy")! }
        if("wind" == self.iconName){ self.wIcon.image = UIImage(named: "weather-windy")! }
        if("fog" == iconName) { self.wIcon.image = UIImage(named: "weather-fog")! }
        if("cloudy" == iconName) { self.wIcon.image = UIImage(named: "weather-cloudy")! }
        if("partly-cloudy-day" == iconName) { self.wIcon.image = UIImage(named: "weather-partly-cloudy")! }
        if("partly-cloudy-night" == iconName) { self.wIcon.image = UIImage(named: "weather-night-partly-cloudy")! }
    }
    
    //
    // createLineGraph
    //
    func createLineGraph()
    {
        // Line Entry on Graph
        let lineData = LineChartData()
        var minChartEntry = [ChartDataEntry]()
        var maxChartEntry = [ChartDataEntry]()

        // Iterate over Min Data
        for i in 0..<minTempData.count
        {
            let entry = ChartDataEntry(x: Double(i), y: minTempData[i])

            // Append Data Point
            minChartEntry.append(entry)
        }
        
        // Iterate over Max Data
        for i in 0..<maxTempData.count
        {
            // Append Data Point
            maxChartEntry.append(ChartDataEntry(x: Double(i), y: maxTempData[i]))
        }
        
        // Create Lines
        let minLine = LineChartDataSet(entries: minChartEntry, label: "Minimum Temperature (°F)")
        let maxLine = LineChartDataSet(entries: maxChartEntry, label: "Maximum Temperature (°F)")

        // Max Line Styling
        maxLine.circleColors = [NSUIColor.orange]
        maxLine.colors = [NSUIColor.orange]
        maxLine.circleRadius = 4.0
        
        // Min Line Styling
        minLine.circleColors = [NSUIColor.white]
        minLine.colors = [NSUIColor.white]
        minLine.circleRadius = 4.0
        
        // Add to Data Set
        lineData.addDataSet(minLine)
        lineData.addDataSet(maxLine)

        // Add to Chart
        self.lineChart.data = lineData
    }
}
