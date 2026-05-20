@preconcurrency import GoogleMobileAds
import SwiftUI
import UIKit

// UIViewRepresentable wrapping GADNativeAdView. Google requires native ads to render
// inside GADNativeAdView for impression and click tracking to work correctly.
@MainActor
struct NativeAdView: UIViewRepresentable {
    let nativeAd: GADNativeAd

    func makeUIView(context: Context) -> GADNativeAdView {
        let adView = GADNativeAdView()

        let headlineLabel = makeHeadlineLabel()
        let bodyLabel = makeBodyLabel()
        let ctaButton = makeCTAButton()

        adView.headlineView = headlineLabel
        adView.bodyView = bodyLabel
        adView.callToActionView = ctaButton
        ctaButton.isUserInteractionEnabled = false // GADNativeAdView owns all tap handling

        let ctaContainer = UIView()
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaContainer.addSubview(ctaButton)
        NSLayoutConstraint.activate([
            ctaButton.centerXAnchor.constraint(equalTo: ctaContainer.centerXAnchor),
            ctaButton.topAnchor.constraint(equalTo: ctaContainer.topAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: ctaContainer.bottomAnchor),
            ctaButton.leadingAnchor.constraint(greaterThanOrEqualTo: ctaContainer.leadingAnchor),
            ctaButton.trailingAnchor.constraint(lessThanOrEqualTo: ctaContainer.trailingAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [headlineLabel, bodyLabel, ctaContainer])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: adView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -16)
        ])

        return adView
    }

    func updateUIView(_ adView: GADNativeAdView, context: Context) {
        (adView.headlineView as? UILabel)?.text = nativeAd.headline
        (adView.bodyView as? UILabel)?.text = nativeAd.body
        (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        adView.nativeAd = nativeAd
    }

    // MARK: - Private Factories

    private func makeHeadlineLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }

    private func makeBodyLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        return label
    }

    private func makeCTAButton() -> UIButton {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(hue: 174.0 / 360.0, saturation: 0.65, brightness: 0.65, alpha: 1.0)
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
        config.cornerStyle = .capsule
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var updated = attrs
            updated.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            return updated
        }
        return UIButton(configuration: config)
    }
}
