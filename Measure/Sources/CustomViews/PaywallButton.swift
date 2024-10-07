import UIKit

final class CustomButton: UIButton {

    // MARK: - UI Elements

    private let topLabel = UILabel()
    private let bottomLabel = UILabel()
    private let rightLabel = UILabel()
    private let checkBoxImageView = UIImageView()
    
    // Свойство для определения, выбрана ли кнопка
    var isChoosen: Bool = false {
        didSet {
            updateCheckBoxState()
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        layer.cornerRadius = 8
        clipsToBounds = false
        backgroundColor = .white
        
        topLabel.textAlignment = .left
        topLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        bottomLabel.textAlignment = .left
        bottomLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        rightLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        
        topLabel.textColor = UIColor(hexString: "#152239")?.withAlphaComponent(0.6)
        rightLabel.textColor = UIColor(hexString: "#152239")?.withAlphaComponent(0.6)
        bottomLabel.textColor = UIColor(hexString: "#152239")?.withAlphaComponent(0.6)
        
        checkBoxImageView.contentMode = .scaleAspectFit

        // Добавляем элементы на кнопку
        addSubview(topLabel)
        addSubview(bottomLabel)
        addSubview(checkBoxImageView)
        addSubview(rightLabel)
        
        // Устанавливаем Auto Layout для элементов
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        checkBoxImageView.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // TopLabel сверху, левая часть
            topLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            topLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            topLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkBoxImageView.leadingAnchor, constant: -8),

            // BottomLabel снизу, левая часть
            bottomLabel.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 4),
            bottomLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            bottomLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkBoxImageView.leadingAnchor, constant: -8),
            bottomLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            // CheckBox справа по центру вертикали
            checkBoxImageView.centerYAnchor.constraint(equalTo: topAnchor, constant: 0),
            checkBoxImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            checkBoxImageView.widthAnchor.constraint(equalToConstant: 110),
            checkBoxImageView.heightAnchor.constraint(equalToConstant: 28),
            
            rightLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])

        // Настраиваем начальное состояние чекбокса
        updateCheckBoxState()
    }

    // MARK: - Public Methods
    
    func configure(topText: String, price: String, periodText: String, period: String, isChosen: Bool) {
        topLabel.text = topText
        
        bottomLabel.text = "Then \(price) /\(period)"
        if period == "year" {
            
            let d = Double(truncating: PremiumManager.shared.annuallyPriceOnly as NSNumber)
            let yearlyWeeklyPrice = d / 52.0
            let roundedWeeklyPrice = (yearlyWeeklyPrice * 100).rounded() / 100
            
            
            rightLabel.text = "\(roundedWeeklyPrice) / month"
            
        } else {
            checkBoxImageView.isHidden = true
            rightLabel.text = "\(PremiumManager.shared.weeklyPriceOnly) / month"
        }
        
        self.isChoosen = isChosen
    }

    // MARK: - Private Methods

    private func createAttributedString(price: String, periodText: String, period: String) -> NSAttributedString {
        let fullText = NSMutableAttributedString()
        
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor(hexString: "#152239")!
        ]
        let priceAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor(hexString: "#152239")!
        ]
        
        let yearlyText = NSAttributedString(string: "Then ", attributes: regularAttributes)
        fullText.append(yearlyText)
        
        let priceText = NSAttributedString(string: price, attributes: priceAttributes)
        fullText.append(priceText)
        
        let period = NSAttributedString(string: " / \(periodText)", attributes: regularAttributes)
        fullText.append(period)
        
        return fullText
    }
    
    // Обновляем изображение чекбокса и обводку в зависимости от выбранного состояния
    private func updateCheckBoxState() {
        let checkBoxImage = isChoosen ? UIImage(named: "mostPopular") : UIImage(named: "mostPopular")
        checkBoxImageView.image = checkBoxImage

        // Устанавливаем обводку в зависимости от состояния кнопки
        if isChoosen {
            layer.borderColor = UIColor.clear.cgColor // Обводка активной кнопки
            layer.borderWidth = 1.0
            topLabel.textColor = UIColor(hexString: "#152239")
            rightLabel.textColor = UIColor(hexString: "#152239")
            bottomLabel.textColor = UIColor(hexString: "#152239")
            backgroundColor = UIColor(hexString: "#D7E7F3")
        } else {
            layer.borderColor = UIColor(hexString: "#475DB6")?.withAlphaComponent(0.25).cgColor // Обводка неактивной кнопки
            layer.borderWidth = 1.0
            topLabel.textColor = UIColor(hexString: "#152239")?.withAlphaComponent(0.6)
            rightLabel.textColor = UIColor(hexString: "#152239")?.withAlphaComponent(0.6)
            bottomLabel.textColor = UIColor(hexString: "#152239")?.withAlphaComponent(0.6)
            backgroundColor = UIColor.white
        }
    }
}
