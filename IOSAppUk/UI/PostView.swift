import UIKit
import Kingfisher

final class PostView: UIView {

    // MARK: - UI
    private let cardView = UIView()

    private let headerLabel = UILabel()
    private let bookmarkButton = UIButton(type: .system)

    private let titleLabel = UILabel()
    private let postImageView = UIImageView()

    private let bottomBar = UIStackView()
    private let ratingLabel = UILabel()
    private let commentsLabel = UILabel()
    private let shareButton = UIButton(type: .system)

    // overlay for animated bookmark
    private let bookmarkOverlayView = UIView()
    private let bookmarkShapeLayer = CAShapeLayer()

    private var post: Post?

    // MARK: - State
    private var saved: Bool = false {
        didSet { updateBookmarkIcon() }
    }

    var onSaveTap: ((Post, Bool) -> Void)?
    var onShareTap: ((Post) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupGesture()
        setupBookmarkOverlay()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLayout()
        setupGesture()
        setupBookmarkOverlay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateBookmarkOverlayPath()
    }

    // MARK: - Public
    func configure(with post: Post) {
        self.post = post

        headerLabel.text = "\(post.username) • \(timeAgo(from: post.createdDate)) • \(post.domain)"
        titleLabel.text = post.title
        ratingLabel.text = "↑ \(formatScore(post.rating))"
        commentsLabel.text = "💬 \(post.numComments)"

        saved = post.isSaved

        if let url = post.imageURL {
            postImageView.kf.setImage(with: url)
        } else {
            postImageView.image = nil
            postImageView.backgroundColor = .tertiarySystemFill
        }
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        addSubview(cardView)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        headerLabel.textColor = .secondaryLabel
        headerLabel.numberOfLines = 1
        cardView.addSubview(headerLabel)

        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        bookmarkButton.tintColor = .label
        bookmarkButton.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)
        cardView.addSubview(bookmarkButton)
        updateBookmarkIcon()

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        cardView.addSubview(titleLabel)

        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.backgroundColor = .tertiarySystemFill
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.isUserInteractionEnabled = true
        cardView.addSubview(postImageView)

        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.axis = .horizontal
        bottomBar.alignment = .center
        bottomBar.distribution = .equalSpacing
        cardView.addSubview(bottomBar)

        ratingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        ratingLabel.textColor = .label

        commentsLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        commentsLabel.textColor = .label

        var config = UIButton.Configuration.plain()
        config.title = "Share"
        config.image = UIImage(systemName: "square.and.arrow.up")
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.baseForegroundColor = .label
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var attrs = attrs
            attrs.font = .systemFont(ofSize: 14, weight: .semibold)
            return attrs
        }
        shareButton.configuration = config
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)

        bottomBar.addArrangedSubview(ratingLabel)
        bottomBar.addArrangedSubview(commentsLabel)
        bottomBar.addArrangedSubview(shareButton)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),

            headerLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            headerLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: bookmarkButton.leadingAnchor, constant: -8),

            bookmarkButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 28),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            postImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            postImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalToConstant: 260),

            bottomBar.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 10),
            bottomBar.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            bottomBar.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            bottomBar.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])
    }

    private func setupGesture() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapImage))
        doubleTap.numberOfTapsRequired = 2
        postImageView.addGestureRecognizer(doubleTap)
    }

    private func setupBookmarkOverlay() {
        bookmarkOverlayView.translatesAutoresizingMaskIntoConstraints = false
        bookmarkOverlayView.backgroundColor = .clear
        bookmarkOverlayView.alpha = 0
        bookmarkOverlayView.isUserInteractionEnabled = false

        postImageView.addSubview(bookmarkOverlayView)

        NSLayoutConstraint.activate([
            bookmarkOverlayView.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor),
            bookmarkOverlayView.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor),
            bookmarkOverlayView.widthAnchor.constraint(equalToConstant: 90),
            bookmarkOverlayView.heightAnchor.constraint(equalToConstant: 90)
        ])

        bookmarkShapeLayer.fillColor = UIColor.clear.cgColor
        bookmarkShapeLayer.strokeColor = UIColor.white.cgColor
        bookmarkShapeLayer.lineWidth = 6
        bookmarkShapeLayer.lineJoin = .round
        bookmarkShapeLayer.lineCap = .round
        bookmarkShapeLayer.shadowColor = UIColor.black.cgColor
        bookmarkShapeLayer.shadowOpacity = 0.25
        bookmarkShapeLayer.shadowRadius = 4
        bookmarkShapeLayer.shadowOffset = CGSize(width: 0, height: 2)

        bookmarkOverlayView.layer.addSublayer(bookmarkShapeLayer)
    }

    private func updateBookmarkOverlayPath() {
        bookmarkOverlayView.layoutIfNeeded()

        let bounds = bookmarkOverlayView.bounds

        guard bounds.width > 0, bounds.height > 0 else { return }

        let rect = bounds.insetBy(dx: 26, dy: 18)
        guard rect.width > 0, rect.height > 0 else { return }

        bookmarkShapeLayer.frame = bounds
        bookmarkShapeLayer.path = makeBookmarkPath(in: rect).cgPath
    }

    private func makeBookmarkPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()

        guard rect.width > 0, rect.height > 0 else { return path }

        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let notch = CGPoint(x: rect.midX, y: rect.maxY - rect.height * 0.28)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)

        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: notch)
        path.addLine(to: bottomLeft)
        path.close()

        return path
    }

    // MARK: - Actions
    @objc private func didTapBookmark() {
        guard let post else { return }
        saved.toggle()
        onSaveTap?(post, saved)
    }

    @objc private func didDoubleTapImage() {
        guard let post else { return }

        saved.toggle()
        onSaveTap?(post, saved)
        animateBookmarkOverlay()
    }

    @objc private func didTapShare() {
        guard let post else { return }
        onShareTap?(post)
    }

    private func animateBookmarkOverlay() {
        bookmarkOverlayView.alpha = 0
        bookmarkOverlayView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
            self.bookmarkOverlayView.alpha = 1
            self.bookmarkOverlayView.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.22, delay: 0.35, options: [.curveEaseIn]) {
                self.bookmarkOverlayView.alpha = 0
                self.bookmarkOverlayView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            }
        }
    }

    private func updateBookmarkIcon() {
        let name = saved ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: name), for: .normal)
    }

    // MARK: - Helpers
    private func formatScore(_ value: Int) -> String {
        if value >= 1_000_000 { return String(format: "%.1fm", Double(value)/1_000_000) }
        if value >= 1_000 { return String(format: "%.1fk", Double(value)/1_000) }
        return "\(value)"
    }

    private func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        let hours = seconds / 3600
        if hours > 0 { return "\(hours)h" }
        let minutes = seconds / 60
        if minutes > 0 { return "\(minutes)m" }
        return "now"
    }
}
