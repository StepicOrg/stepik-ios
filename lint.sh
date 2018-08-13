if [ -f "${PODS_ROOT}/SwiftLint/swiftlint" ]; then
    ${PODS_ROOT}/SwiftLint/swiftlint autocorrect
    ${PODS_ROOT}/SwiftLint/swiftlint lint --config ${SRCROOT}/.swiftlint.yml
else
    echo "warning: SwiftLint not installed, run pod install"
fi