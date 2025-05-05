import http from 'k6/http';

import { sleep } from 'k6';

export const options = {
    vus: 100,
    duration: '100s'
};

export default function () {
    let url = 'http://localhost';
    let port = '5400'
    let search_path = '/rapid_api_search'
    let root_path = '/'
    let test_path = '/test'
    let paths = [search_path, root_path, test_path]
    
    for (let path of paths) {
        http.get(url + ':' + port + path);
        console.log(url + ":" + port + path)
        sleep(0.3)
    }
}