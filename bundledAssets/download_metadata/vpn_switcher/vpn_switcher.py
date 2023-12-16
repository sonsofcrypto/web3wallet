import os
import pathlib
import time
import random
from typing import List
from inspect import getsourcefile
from os.path import abspath
from multiprocessing import Process


class VPNSwitcherInterface:

    def connect(self, profile: str):
        """Connect to profile"""
        pass

    def next(self, profile: str):
        """Connects to next available profile"""
        pass


def curr_file_path() -> str:
    path = abspath(getsourcefile(lambda: 0))
    return os.path.split(path)[0]


def execute_cmd(cmd: str):
    result = os.system(cmd)
    print("result", result)


class VPNSwitcher(VPNSwitcherInterface):
    profiles: List[str]

    def __init__(
        self,
        vpn_user: str,
        vpn_pass: str,
        profiles_path: str = curr_file_path() + '/vpn_profiles'
    ):
        self.vpn_user = vpn_user
        self.vpn_pass = vpn_pass
        self.profiles = self.__load_profiles(profiles_path)
        self.profiles_path = profiles_path
        self.curr_profile_idx = -1
        self.process: Process = None

    def connect(self, profile: str):
        print("Connection profile", profile)
        cmd = 'sudo bash -c \'openvpn --config {} --auth-user-pass <(echo "{}"; echo "{}")\' &'.format(
            self.profiles_path + '/' + profile,
            self.vpn_user,
            self.vpn_pass
        )
        if self.process is not None:
            self.process.kill()
            time.sleep(1)
            os.system('sudo killall openvpn')
            time.sleep(1)
        self.process = Process(target=execute_cmd, args=(cmd,))
        self.process.start()
        # need to sleep 5 min / len(profiles) to ensure each profile is hit at
        # most once every 5 min.
        time.sleep(300.0 / float(len(self.profiles)) + 1)

    def next(self):
        self.curr_profile_idx += 1
        if self.curr_profile_idx >= len(self.profiles):
            self.curr_profile_idx = 0
        self.connect(self.profiles[self.curr_profile_idx])

    def __load_profiles(self, path: str) -> List[str]:
        profiles = os.listdir(path)
        # profiles = reversed(profiles)
        random.shuffle(profiles)
        return profiles


class SleepSwitcher(VPNSwitcherInterface):
    """
    Used for mocking switching VPN. Rather than switching it just sleep instead.
    """

    def __init__(self, sleep_period: int):
        self.sleep_period = sleep_period

    def connect(self, profile: str):
        time.sleep(self.sleep_period)

    def next(self, profile: str):
        time.sleep(self.sleep_period)
