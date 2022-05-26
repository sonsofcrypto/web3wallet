// SPDX-License-Identifier: MIT
package bip39

import (
	"bufio"
	"fmt"
	"os"
)

// ListLang bip39 compliant word list language
type ListLang string

const (
	ListLangEn    ListLang = "english"
	ListLangEs    ListLang = "spanish"
	ListLangFr    ListLang = "french"
	ListLangIt    ListLang = "italian"
	ListLangPt    ListLang = "portuguese"
	ListLangCz    ListLang = "czech"
	ListLangJp    ListLang = "japanese"
	ListLangKr    ListLang = "korean"
	ListLangZhCHS ListLang = "chinese_simplified"
	ListLangZhCHT ListLang = "chinese_traditional"
)

// SupportedListLanguages list of all supported `ListLang`
func SupportedListLanguages() []ListLang {
	return []ListLang{
		ListLangEn,
		ListLangEs,
		ListLangFr,
		ListLangIt,
		ListLangPt,
		ListLangCz,
		ListLangJp,
		ListLangKr,
		ListLangZhCHS,
		ListLangZhCHT,
	}
}

func LoadWordList(lang ListLang, path string) ([]string, error) {
	file, err := os.Open(fmt.Sprintf("%s/%s.txt", path, lang))
	if err != nil {
		return nil, err
	}
	defer file.Close()

	idx := 0
	list := make([]string, 2048)
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		list[idx] = scanner.Text()
		idx++
	}

	if err := scanner.Err(); err != nil {
		return list, err
	}

	return list, nil
}

func LoadAllWordLists(path string) ([][]string, error) {
	listsCnt := len(SupportedListLanguages())
	lists := make([][]string, listsCnt)
	jobs := make(chan listLoadJob, listsCnt)
	results := make(chan listLoadResult, listsCnt)

	for w := 0; w < listsCnt; w++ {
		go listLoadWorker(w, jobs, results)
	}

	for _, lang := range SupportedListLanguages() {
		jobs <- listLoadJob{lang, path}
	}

	close(jobs)

	for a := 1; a <= listsCnt; a++ {
		result := <-results
		if result.err != nil {
			return nil, result.err
		}
		lists = append(lists, result.list)
	}

	return lists, nil
}

func listLoadWorker(id int, jobs <-chan listLoadJob, results chan<- listLoadResult) {
	for j := range jobs {
		list, err := LoadWordList(j.lang, j.path)
		results <- listLoadResult{list, err}
	}
}

type listLoadJob struct {
	lang ListLang
	path string
}

type listLoadResult struct {
	list []string
	err  error
}
