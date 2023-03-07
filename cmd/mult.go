/*
Copyright © 2023 Admir Trakic <atrakic@users.noreply.github.com>
*/
package cmd

import (
	"fmt"
	"strconv"

	"github.com/spf13/cobra"
)

// multCmd represents the mult command
var multCmd = &cobra.Command{
	Use:   "mult",
	Short: "Multiply numbers",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {
		mult(args)
	},
}

func init() {
	rootCmd.AddCommand(multCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// multCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// multCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}

func mult(arg []string) {
	a, _ := strconv.ParseFloat(arg[0], 64)
	res := a

	for _, i := range arg {
		s, _ := strconv.ParseFloat(i, 64)

		if i == arg[0] {
			continue
		}

		res *= s

	}

	fmt.Printf("%v \n", res)
}

/*
func mult(arg []string) {
	var res float64

	for _, v := range arg {
		i, _ := strconv.ParseFloat(v, 64)
		res *= i
	}

	fmt.Printf("%v \n", res)
}
*/
