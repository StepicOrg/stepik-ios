target_name=$1

if [[ $target_name == "Stepic" ]]; then
	path="${PWD}/Stepic/Sources"
elif [[ $target_name == "StepicUITests" ]]; then
	path="${PWD}/StepicUITests"
else
	echo "warning: unknown target name ${target_name}"
fi

if [[ -z $path ]]; then
	exit 1
fi

swiftlint_executable="${PWD}/Pods/SwiftLint/swiftlint"

if [[ -f $swiftlint_executable ]]; then
	$swiftlint_executable lint --config "${PWD}/.swiftlint.yml" "$path"
else
	echo "warning: SwiftLint not installed, run pod install"
fi
